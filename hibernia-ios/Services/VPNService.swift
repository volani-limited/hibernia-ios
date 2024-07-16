//
//  VPNService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 01/10/2022.
//

import Foundation
import Combine

import TunnelKitCore
import TunnelKitManager
import TunnelKitOpenVPN

import NetworkExtension

import FirebaseAppCheck

@MainActor
class VPNService: ObservableObject {
    static let tunnelIdentifier = "uk.co.volani.hibernia-ios.OpenVPNTunnel" // Define identifiers
    static let appGroup = "group.uk.co.volani.hibernia-ios"
    
    @Published var status: HiberniaVPNStatus // Define published varibles
    @Published var destination: VPNDestination
    
    @Published var keepAlive: Bool
    @Published var killSwitch: Bool
    @Published var connectedTime: String
    
    @Published var vpnIP: String?
    
    var timer: SimpleTimerService
    
    var apiEndpoint: String
    
    private var configuration: OpenVPN.Configuration?
    private var subscriptions: Set<AnyCancellable>
    private var vpn: NetworkExtensionVPN

    init() {
        vpn = NetworkExtensionVPN()
        status = .disconnected
        timer = SimpleTimerService()
        connectedTime = "--:--"
        
        //apiEndpoint = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? "https://europe-west2-hiberniavpn.cloudfunctions.net/v2-provision-configuration" : "https://europe-west2-hiberniavpn.cloudfunctions.net/v2-sandbox-provision-configuration"

        apiEndpoint = "https://europe-west2-hiberniavpn.cloudfunctions.net/v3-provision-configuration"
        
        let defaults = UserDefaults.standard // Load data from userdefaults
        destination = VPNDestination(rawValue: defaults.string(forKey: "destination") ?? "lon") ?? .lon
        
        keepAlive = defaults.bool(forKey: "keepAlive")
        killSwitch = defaults.bool(forKey: "keepAlive")
        
        subscriptions = Set<AnyCancellable>()
        
        subscriptions.insert($destination.sink { value in
            defaults.set(value.rawValue, forKey: "destination")
        })
        subscriptions.insert($keepAlive.sink { value in
            defaults.set(value, forKey: "keepAlive")
        })
        subscriptions.insert($killSwitch.sink { value in
            defaults.set(value, forKey: "killSwitch")
        })
        
        timer.$elapsedTime.map {
            let formatter = DateComponentsFormatter() // Use dateFormatter to convert date interval into minutes and seconds
            
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad
            formatter.unitsStyle = .positional
            
            
            if let output = formatter.string(from: $0) {
                return output // return this value
            } else {
                return  "--:--" // if formatter fails return blank value
            }
        }.assign(to: &$connectedTime) // Assign elapsed time to published varible
        
        
        NotificationCenter.default.addObserver( // Add notification observers to VPN manager
            self,
            selector: #selector(VPNStatusDidChange(notification:)),
            name: VPNNotification.didChangeStatus,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNDidFail(notification:)),
            name: VPNNotification.didFail,
            object: nil
        )
    }
    
    deinit {
        let _ = subscriptions.map({ $0.cancel() }) // Remove subscriptions if manager removed.
    }

    func prepare() async {
        await vpn.prepare()
    }
    
    @MainActor
    func connect(appUserId: String) async throws { // Connect by first retreiving configuration, creating provider configuration and connecting to the VPN
        do {
            self.status = .requestingConfiguration

            self.configuration = try await self.requestConfiguration(destination: self.destination, appUserId: appUserId)
            
            let providerConfiguration = OpenVPN.ProviderConfiguration("HiberniaVPN", appGroup: VPNService.appGroup, configuration: self.configuration!)
           
            var configurationExtras = NetworkExtensionExtra()
            
            configurationExtras.disconnectsOnSleep = false
            configurationExtras.killSwitch = killSwitch
            
            if keepAlive {
                configurationExtras.onDemandRules = [NEOnDemandRuleConnect()]
            }
            
            try await vpn.reconnect(VPNService.tunnelIdentifier, configuration: providerConfiguration, extra: configurationExtras, after: .seconds(1))

            self.vpnIP = providerConfiguration.configuration.ipv4?.address
        } catch {
            if let urlError = error as? URLError, urlError.code == URLError.Code.cancelled {
                return // Hide error if cancelled
            }

            self.status = .disconnected
            throw error
        }
    }
    
    func disconnect() {
        Task {
            await vpn.disconnect()
        }
    }
    
    func requestConfiguration(destination: VPNDestination, appUserId: String) async throws -> OpenVPN.Configuration {
        let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false) // Get app check token
        
        let url = URL(string: apiEndpoint + "?location=\(destination.rawValue)") // Create request url

        var request = URLRequest(url: url!)
        
        request.setValue(appCheckToken.token, forHTTPHeaderField: "App-Check-Token")
        request.setValue(appUserId, forHTTPHeaderField: "App-User-Id")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpsResponse = response as? HTTPURLResponse else { // Make request and handle error
            throw VPNError.configurationRequestError
        }
        
        if  httpsResponse.statusCode == 200 {
            let decodedData = try JSONDecoder().decode(ConfigurationResponse.self, from: data)
            let parser = try OpenVPN.ConfigurationParser.parsed(fromContents: decodedData.configuration) // Decode configuration and return
            
            return parser.configuration
        } else if httpsResponse.statusCode == 402 { // If return is due to payment error display this
            throw VPNError.subscriptionPaymentError
        } else {
            throw VPNError.configurationRequestError
        }
    }
    
    @objc private func VPNStatusDidChange(notification: Notification) { // start and stop timer for status change
        switch notification.vpnStatus {
        case .connected:
            
            Task {
                self.vpnIP = try await DestinationPingService.ping(hostname: destination.hostname, interval: 1, timeout: 5, attempts: 1).responses.first(where: {$0.ipAddress != nil})?.ipAddress
            }
            
            status = .connected
        case .connecting:
            status = .connecting
        case .disconnected:
            status = .disconnected
        case .disconnecting:
            status = .disconnecting
        }
        
        print("VPNStatusDidChange: \(status)")
        
        if status == .connected {
            timer.reset()
            timer.start()
        } else if status == .disconnecting {
            timer.stop()
        }
    }

    @objc private func VPNDidFail(notification: Notification) {
        print("VPNStatusDidFail: \(notification.vpnError.localizedDescription)") // TODO: Handle this error here?
    }
}

struct ConfigurationResponse: Codable {
    let response: String
    let configuration: String
}

enum VPNDestination: String, CaseIterable { // Define destinations TODO: Update with remote config
    case lon
    case sgy
    case nyc
    case tyo
    case syd
    case dal
    case fra
    case mum
    
    var displayed: String {
        switch self {
        case .lon:
            return "🇬🇧 London"
        case .sgy:
            return "🇸🇬 Singapore"
        case .nyc:
            return "🇺🇸 New York"
        case .tyo:
            return "🇯🇵 Tokyo"
        case .syd:
            return "🇦🇺 Sydney"
        case .dal:
            return "🇺🇸 Dallas"
        case .fra:
            return "🇩🇪 Frankfurt"
        case .mum:
            return "🇮🇳 Mumbai"
        }
    }
    
    var hostname: String {
        switch self {
        case .lon:
            return "lon-1.vpn.hiberniavpn.com"
        case .sgy:
            return "sgy-1.vpn.hiberniavpn.com"
        case .nyc:
            return "nyc-1.vpn.hiberniavpn.com"
        case .tyo:
            return "tyo-1.vpn.hiberniavpn.com"
        case .syd:
            return "syd-1.vpn.hiberniavpn.com"
        case .dal:
            return "dal-1.vpn.hiberniavpn.com"
        case .fra:
            return "fra-1.vpn.hiberniavpn.com"
        case .mum:
            return "mum-1.vpn.hiberniavpn.com"
        }
    }
}


enum VPNError: LocalizedError {
    case configurationRequestError
    case subscriptionPaymentError
    
    public var errorDescription: String? { // Define VPN specific errors
        switch self {
        case .configurationRequestError:
            return "Configuration request failed."
        case .subscriptionPaymentError:
            return "Subscription could not be verified."
        }
    }
}

enum HiberniaVPNStatus: String {
    case requestingConfiguration = "Requesting Configuration"
    case connecting = "Connecting"
    case connected = "Connected"
    case disconnecting = "Disconnecting"
    case disconnected = "Disconnected"
}
