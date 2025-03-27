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
class VPNServiceOld: ObservableObject {
    static let tunnelIdentifier = "uk.co.volani.hibernia-ios.OpenVPNTunnel" // Define identifiers
    static let appGroup = "group.uk.co.volani.hibernia-ios"
    
    @Published var status: HiberniaVPNStatus // Define published varibles
    @Published var selectedDestination: VPNDestination
    
    @Published var keepAlive: Bool
    @Published var killSwitch: Bool
    @Published var connectedTime: String
    
    @Published var vpnIP: String?
    @Published var vpnHostname: String?
    
    var timer: SimpleTimerService

    private var subscriptions: Set<AnyCancellable>
    private var vpn: NetworkExtensionVPN

    init(destinations: [VPNDestination]) {
        vpn = NetworkExtensionVPN()
        status = .disconnected
        timer = SimpleTimerService()
        connectedTime = "--:--"
        
        let defaults = UserDefaults.standard // Load data from userdefaults
        selectedDestination = destinations.first(where: { $0.id == defaults.string(forKey: "destination")}) ?? destinations.first! // Make selectedDestination nil if no selected destination
        
        keepAlive = defaults.bool(forKey: "keepAlive")
        killSwitch = defaults.bool(forKey: "keepAlive")
        
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
        }
        .assign(to: &$connectedTime) // Assign elapsed time to published varible
        
        
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
