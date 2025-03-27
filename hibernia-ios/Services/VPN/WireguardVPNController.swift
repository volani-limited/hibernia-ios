//
//  WireguardVPNController.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 27/03/2025.
//

import Foundation
import NetworkExtension

class WireguardVPNController {
    static let tunnelIdentifier = "uk.co.volani.hibernia-ios.WireguardVPNManager"
    
    func connect(with configuration: WireguardVPNConfiguration) async throws {
        let existingManagers: [NETunnelProviderManager] = try await withCheckedThrowingContinuation { continuation in
            NETunnelProviderManager.loadAllFromPreferences { tunnelManagers, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: tunnelManagers!)
                }
            }
        }
        
        let manager = existingManagers.first { $0.localizedDescription == "HiberniaVPN Dedicated"} ?? NETunnelProviderManager()
        manager.localizedDescription = "HiberniaVPN Dedicated"
        
        let protocolConfiguration = NETunnelProviderProtocol()
        
        protocolConfiguration.providerBundleIdentifier = WireguardVPNController.tunnelIdentifier
        protocolConfiguration.serverAddress = configuration.endpoint
        protocolConfiguration.disconnectOnSleep = false

        try protocolConfiguration.providerConfiguration = configuration.asDictionary()
        
        manager.onDemandRules = [NEOnDemandRuleConnect()]
        manager.isOnDemandEnabled = configuration.keepAlive
        
        manager.protocolConfiguration = protocolConfiguration
        manager.isEnabled = true
        
        try await manager.saveToPreferences()
        try await manager.loadFromPreferences()
        
        guard let session = manager.connection as? NETunnelProviderSession else {
            fatalError("tunnel manager.connection is invalid")
        }
        
        try session.startTunnel()
    }
    
    func disconnect() async throws {
        let existingManagers: [NETunnelProviderManager] = try await withCheckedThrowingContinuation { continuation in
            NETunnelProviderManager.loadAllFromPreferences { tunnelManagers, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: tunnelManagers!)
                }
            }
        }
        
        let manager = existingManagers.first { $0.localizedDescription == "HiberniaVPN Dedicated"} ?? NETunnelProviderManager()
       
        guard let session = manager.connection as? NETunnelProviderSession else {
            fatalError("tunnel manager.connection is invalid")
        }
        
        session.stopTunnel()
    }
}

struct WireguardVPNConfiguration: Codable {
    var privateKey: String
    let address: String
    let dns: String
    
    let publicKey: String
    let allowedIPs: String
    let endpoint: String
    
    var keepAlive: Bool
    
    enum CodingKeys: String, CodingKey {
        case address
        case dns
        case publicKey = "public_key"
        case privateKey = "private_key"
        case allowedIPs = "allowed_ips"
        case endpoint
    }
    
    init(address: String, dns: String, publicKey: String, allowedIPs: String, endpoint: String) {
        self.privateKey = ""
        self.keepAlive = false
        
        self.address = address
        self.dns = dns
        self.publicKey = publicKey
        self.allowedIPs = allowedIPs
        self.endpoint = endpoint
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.address = try container.decode(String.self, forKey: .address)
        self.dns = try container.decode(String.self, forKey: .dns)
        self.publicKey = try container.decode(String.self, forKey: .publicKey)
        self.allowedIPs = try container.decode(String.self, forKey: .allowedIPs)
        self.endpoint = try container.decode(String.self, forKey: .endpoint)
        
        self.privateKey = "" // Private key is not decoded as it is recieved separatly.
                             // Note: It may be wise to decompose this struct into actual configuration that is handed to the VPNController and the configuration recieved from server to avoid this workaround.
        self.keepAlive = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(address, forKey: .address)
        try container.encode(dns, forKey: .dns)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encode(allowedIPs, forKey: .allowedIPs)
        try container.encode(endpoint, forKey: .endpoint)
        
        try container.encode(privateKey, forKey: CodingKeys.privateKey)
    }
}
