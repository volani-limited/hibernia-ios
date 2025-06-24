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
    @Published var selectedDestination: VPNDestination
    
    @Published var keepAlive: Bool
    @Published var killSwitch: Bool
    @Published var connectedDate: Date?
    
    @Published var vpnIP: String?
    @Published var vpnHostname: String?

    private var subscriptions: Set<AnyCancellable>
    private var vpn: NetworkExtensionVPN
    
    private static let formatter: DateComponentsFormatter = { // Create and cache DateComponentsFormmatter for use in getConnec
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return formatter
    }()

    init(destinations: [VPNDestination]) {
        vpn = NetworkExtensionVPN()
        status = .disconnected
        
        let defaults = UserDefaults.standard // Load data from userdefaults
        selectedDestination = destinations.first(where: { $0.id == defaults.string(forKey: "destination")}) ?? destinations.first! // Make selectedDestination nil if no selected destination
        
        keepAlive = defaults.bool(forKey: "keepAlive")
        killSwitch = defaults.bool(forKey: "keepAlive")
        
        if let connectedTimeIntervalSince1970 = defaults.object(forKey: "connectedDate") as? Double {
            connectedDate = Date(timeIntervalSince1970: connectedTimeIntervalSince1970)
        }
        
        subscriptions = Set<AnyCancellable>()
        
        subscriptions.insert($selectedDestination.sink { value in
            defaults.set(value.id, forKey: "destination")
        })
        subscriptions.insert($keepAlive.sink { value in
            defaults.set(value, forKey: "keepAlive")
        })
        subscriptions.insert($killSwitch.sink { value in
            defaults.set(value, forKey: "killSwitch")
        })
        subscriptions.insert($connectedDate.sink { value in
            if let value = value {
                defaults.set(value.timeIntervalSince1970, forKey: "connectedDate")
            } else {
                defaults.removeObject(forKey: "connectedDate")
            }
        })
        
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
    
    func getConnectedTime() -> String { // Use a helper function to compute the connected time from the connected date (this allows views to control their updates with TimelineView as opposed to running the timer here)
        guard let connectedDate = connectedDate else { return "--:--:--" }
        
        let interval = Date().timeIntervalSince(connectedDate)
        
        return Self.formatter.string(from: interval) ?? "--:--:--"
    }
    
    @MainActor
    func connect(appUserId: String) async throws { // Connect by first retreiving configuration, creating provider configuration and connecting to the VPN
        do {
            self.status = .requestingConfiguration

            let configuration = try await self.requestConfiguration(appUserId: appUserId)
            
            let providerConfiguration = OpenVPN.ProviderConfiguration("HiberniaVPN", appGroup: VPNService.appGroup, configuration: configuration)
           
            var configurationExtras = NetworkExtensionExtra()
            
            configurationExtras.disconnectsOnSleep = false
            configurationExtras.killSwitch = killSwitch
            
            if keepAlive {
                configurationExtras.onDemandRules = [NEOnDemandRuleConnect()]
            }
            
            try await vpn.reconnect(VPNService.tunnelIdentifier, configuration: providerConfiguration, extra: configurationExtras, after: .seconds(1))

            self.vpnIP = providerConfiguration.configuration.ipv4?.address
            self.vpnHostname = providerConfiguration.configuration.remotes?[0].address
        } catch {
            if let urlError = error as? URLError, urlError.code == URLError.Code.cancelled {
                return // Hide error if cancelled
            }

            self.status = .disconnected
            throw error
        }
    }
    
    func disconnect() async {
        await vpn.disconnect()
    }
    
    func requestConfiguration(appUserId: String) async throws -> OpenVPN.Configuration {
        let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false) // Get app check token
        
        let apiEndpoint = "https://europe-west2-hiberniavpn.cloudfunctions.net/v3-provision-configuration"
        
        let url = URL(string: apiEndpoint + "?location=\(self.selectedDestination.id)") // Create request url

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
                do {
                    self.vpnIP = try await DestinationPingService.ping(hostname: (selectedDestination.id + ".vpn.hiberniavpn.com"), interval: 1, timeout: 5, attempts: 1).responses.first(where: {$0.ipAddress != nil})?.ipAddress
                } catch {
                    print("Could not determine VPN IP")
                }
            }
            
            connectedDate = notification.connectionDate
            
            status = .connected
        case .connecting:
            status = .connecting
        case .disconnected:
            status = .disconnected
            
            connectedDate = nil
        case .disconnecting:
            status = .disconnecting
        }
        
        print("VPNStatusDidChange: \(status)")
    }

    @objc private func VPNDidFail(notification: Notification) {
        print("VPNStatusDidFail: \(notification.vpnError.localizedDescription)") // TODO: Handle this error here?
        Task {
            await self.disconnect()
        }
    }
    
    struct ConfigurationResponse: Codable {
        let response: String
        let configuration: String
    }
    
    struct VPNDestination: Identifiable, Hashable, Codable {
        var id: String
        var displayedName: String
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
