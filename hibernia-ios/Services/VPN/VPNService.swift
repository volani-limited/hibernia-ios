//
//  VPNService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 28/02/2025.
//

import Foundation
import Combine

import TunnelKitCore
import TunnelKitManager
import TunnelKitOpenVPN

import NetworkExtension

import FirebaseAppCheck

import CryptoKit

@MainActor
class VPNService: ObservableObject {
    static let appGroup = "group.uk.co.volani.hibernia-ios"

    @Published var status: HiberniaVPNStatus
    
    @Published var selectedDestination: VPNDestination
    
    @Published var keepAlive: Bool
    @Published var connectedTime: String
    
    var vpnIP: String?
    var vpnHostname: String?
    
    private var subscriptions: Set<AnyCancellable>

    private var classicVPNController: OpenVPNController
    private var dedicatedVPNController: WireguardVPNController
    
    private var timer: SimpleTimerService
    
    init(destinations: [VPNDestination]) {
        classicVPNController = OpenVPNController()
        dedicatedVPNController = WireguardVPNController()
        
        timer = SimpleTimerService()
        connectedTime = "--:--"
        status = .disconnected
        
        let defaults = UserDefaults.standard // Load data from userdefaults
        selectedDestination = destinations.first(where: { $0.id == defaults.string(forKey: "destination")}) ?? destinations.first!
        
        keepAlive = defaults.bool(forKey: "keepAlive")
        
        subscriptions = Set<AnyCancellable>()
        
        subscriptions.insert($selectedDestination.sink { value in
            defaults.set(value.id, forKey: "destination")
        })
        
        subscriptions.insert($keepAlive.sink { value in
            defaults.set(value, forKey: "keepAlive")
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
                .assign(to: &$connectedTime) // Assign elapsed time to published variable
        
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
        let _ = subscriptions.map({ $0.cancel() })
    }
    
    public func prepare() async {
        await classicVPNController.prepare()
    }
    
    public func connect(appUserId: String) async throws {
        await classicVPNController.disconnnect()
        try await dedicatedVPNController.disconnect()
        
        self.status = .requestingConfiguration
        
        switch selectedDestination.type {
        case .classic:
            let configuration = try await requestClassicConfiguration(appUserId: appUserId)
            let providerConfiguration = OpenVPN.ProviderConfiguration("HiberniaVPN Classic", appGroup: VPNService.appGroup, configuration: configuration)
                       
            var configurationExtras = NetworkExtensionExtra()
            configurationExtras.disconnectsOnSleep = false
            
            if keepAlive {
                configurationExtras.onDemandRules = [NEOnDemandRuleConnect()]
            }

            try await classicVPNController.connect(with: providerConfiguration, extras: configurationExtras)
        case .dedicated:
            let configuration = try await requestDedicatedConfiguration(appUserId: appUserId)
            try await dedicatedVPNController.connect(with: configuration)
        }
    }
    
    public func disconnect() async {
        await classicVPNController.disconnnect()
        try! await dedicatedVPNController.disconnect()
    }
    
    private func requestClassicConfiguration(appUserId: String) async throws -> OpenVPN.Configuration {
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
            let configurationRepsonse = try JSONDecoder().decode(ConfigurationRepsonse.self, from: data)
            let parser = try OpenVPN.ConfigurationParser.parsed(fromContents: configurationRepsonse.configuration) // Decode configuration and return
            
            return parser.configuration
        } else if httpsResponse.statusCode == 402 { // If return is due to payment error display this
            throw VPNError.subscriptionPaymentError
        } else {
            throw VPNError.configurationRequestError
        }
    }
    
    private func requestDedicatedConfiguration(appUserId: String) async throws -> WireguardVPNConfiguration {
        
        return WireguardVPNConfiguration(privateKey: "sLybemb2F2oWILfh8KuHKeVAwQQoVydM0mrzYbz582s", keepAlive: true, address: "10.8.8.2/30", dns: "1.1.1.1", publicKey: "vNj79aoRtoSUMwrOHTIUAJhkUxqikmP", endpoint: "157.245.39.74:51820")
        func generateWireguardKeyPair() -> (publicKey: String, privateKey: String) {
            let privateKey = Curve25519.KeyAgreement.PrivateKey()
            let publicKey = privateKey.publicKey.rawRepresentation
            
            return (privateKey.rawRepresentation.base64EncodedString(), publicKey.base64EncodedString())
        }
        
        let keypair = generateWireguardKeyPair()
        
        let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false)
        
        let apiEndpoint = "https://europe-west2-hiberniavpn.cloudfunctions.net/v1-provision-server"
        
        let url = URL(string: apiEndpoint + "?location=\(self.selectedDestination.id)&publicKey=\(keypair.publicKey)") // Create request url
        
        var request = URLRequest(url: url!)

        request.setValue(appCheckToken.token, forHTTPHeaderField: "App-Check-Token")
        request.setValue(appUserId, forHTTPHeaderField: "App-User-Id")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpsResponse = response as? HTTPURLResponse else { // Make request and handle error
            throw VPNError.configurationRequestError
        }
        
        if  httpsResponse.statusCode == 200 {
            let configurationResponse = try JSONDecoder().decode(ConfigurationRepsonse.self, from: data)
            
            var configuration = try JSONDecoder().decode(WireguardVPNConfiguration.self, from: configurationResponse.configuration.data(using: .utf8)!)
            
            
            configuration.privateKey = keypair.privateKey // Set additional configuration parameters
            configuration.keepAlive = self.keepAlive
            
            return configuration
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
