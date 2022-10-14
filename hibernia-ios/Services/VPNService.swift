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

class VPNService: ObservableObject {
    static let tunnelIdentifier = "uk.co.volani.hibernia-ios.OpenVPNTunnel"
    static let appGroup = "group.uk.co.volani.hibernia-ios"
    
    @Published var status: VPNStatus
    @Published var destination: VPNDestination
    @Published var vpnServiceError: Error?
    @Published var retryHandler: (() -> Void)?
    
    var configuration: OpenVPN.Configuration?
    
    var destinationUpdater: AnyCancellable?
    
    var vpn: NetworkExtensionVPN

    init() {
        vpn = NetworkExtensionVPN()
        status = .disconnected

        let defaults = UserDefaults.standard
        destination = VPNDestination(rawValue: defaults.string(forKey: "destination") ?? "lon")!
        
        destinationUpdater = $destination.sink { value in
            defaults.set(value.rawValue, forKey: "destination")
        }
        
        NotificationCenter.default.addObserver(
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
        destinationUpdater?.cancel()
    }

    func prepare() async {
        await vpn.prepare()
    }
    
    @MainActor
    func connect(transactionID: UInt64, authKey: String) async {
        do {
            self.configuration = try await self.requestConfiguration(destination: self.destination, transactionID: transactionID, authKey: authKey)
            
            let providerConfiguration = OpenVPN.ProviderConfiguration("HiberniaVPN", appGroup: VPNService.appGroup, configuration: self.configuration!)
            
            try await vpn.reconnect(VPNService.tunnelIdentifier, configuration: providerConfiguration, extra: nil, after: .seconds(2))
            
            self.vpnServiceError = nil
            self.retryHandler = nil
        } catch {
            self.vpnServiceError = error
            self.status = .disconnected
        }
    }
    
    func disconnect() {
        Task {
            await vpn.disconnect()
        }
    }
    
    func requestConfiguration(destination: VPNDestination, transactionID: UInt64, authKey: String) async throws -> OpenVPN.Configuration {
        let url = URL(string: "https://provision-configuration-1-xgpoqrynja-lm.a.run.app?token=\(authKey)&subscription_id=\(transactionID)&location=\(destination.rawValue)")
        let request = URLRequest(url: url!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        
        guard let httpsResponse = response as? HTTPURLResponse else {
            throw VPNError.configurationRequestError
        }
        
        if  httpsResponse.statusCode == 200 {
            let decodedData = try JSONDecoder().decode(ConfigurationResponse.self, from: data)
            let parser = try OpenVPN.ConfigurationParser.parsed(fromContents: decodedData.configuration)
            
            return parser.configuration
        } else if httpsResponse.statusCode == 402 {
            throw VPNError.subscriptionPaymentError
        } else {
            throw VPNError.configurationRequestError
        }
    }
    
    @objc private func VPNStatusDidChange(notification: Notification) {
        status = notification.vpnStatus
        print("VPNStatusDidChange: \(status)")
    }

    @objc private func VPNDidFail(notification: Notification) {
        print("VPNStatusDidFail: \(notification.vpnError.localizedDescription)")
    }
}

struct ConfigurationResponse: Codable {
    let response: String
    let configuration: String
}

enum VPNDestination: String , CaseIterable {
    case lon
    case sgy
    case nyc
    
    var displayed: String {
        switch self {
        case .lon:
            return "London 🇬🇧"
        case .sgy:
            return "Singapore 🇸🇬"
        case .nyc:
            return "New York 🇺🇸"
        }
    }
}


enum VPNError: LocalizedError {
    case configurationRequestError
    case subscriptionPaymentError
    
    public var errorDescription: String? {
        switch self {
        case .configurationRequestError:
            return "Configuration request failed."
        case .subscriptionPaymentError:
            return "Subscription could not be verified."
        }
    }
}
