//
//  VPNService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 01/10/2022.
//

import Foundation

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
    
    var vpn: NetworkExtensionVPN

    init() {
        vpn = NetworkExtensionVPN()
        status = .disconnected

        destination = .london
        
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
    
    func prepare() async {
        await vpn.prepare()
    }
    
    @MainActor
    func connect(transactionID: UInt64, authKey: String) async {
        do {
            self.configuration = try await self.requestConfiguration(destination: self.destination, transactionID: transactionID, authKey: authKey)
            
            let providerConfiguration = OpenVPN.ProviderConfiguration("HiberniaVPN", appGroup: VPNService.appGroup, configuration: self.configuration!)
            
            try await vpn.reconnect(VPNService.tunnelIdentifier, configuration: providerConfiguration, extra: nil, after: .seconds(2))
        } catch {
            self.vpnServiceError = error
        }
    }
    
    func disconnect() {
        Task {
            await vpn.disconnect()
        }
    }
    
    func requestConfiguration(destination: VPNDestination, transactionID: UInt64, authKey: String) async throws -> OpenVPN.Configuration {
        let url = URL(string: "https://sandbox-provision-certificate-xgpoqrynja-ew.a.run.app?token=\(authKey)&subscription_id=\(transactionID)&location=\(destination.code)")
        let request = URLRequest(url: url!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpsResponse = response as? HTTPURLResponse, httpsResponse.statusCode == 200 {
            let decodedData = try JSONDecoder().decode(ConfigurationResponse.self, from: data)
            let parser = try OpenVPN.ConfigurationParser.parsed(fromContents: decodedData.configuration)
            
            return parser.configuration
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
    case london = "London 🇬🇧"
    case singapore = "Singapore 🇸🇬"
    case newyork = "New York 🇺🇸"
    
    var code: String {
        switch self {
        case .london:
            return "lon"
        case .singapore:
            return "sgy"
        case .newyork:
            return "nyc"
        }
    }
}


enum VPNError: Error {
    case configurationRequestError
}
