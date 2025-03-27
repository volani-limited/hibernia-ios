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
        manager.isOnDemandEnabled = configuration.keepAlive ?? false
        
        manager.protocolConfiguration = protocolConfiguration
        manager.isEnabled = true
        
        try await manager.saveToPreferences()
        try await manager.loadFromPreferences()
        
        guard let session = manager.connection as? NETunnelProviderSession else {
            fatalError("tunnelManager.connection is invalid")
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
            fatalError("tunnelManager.connection is invalid")
        }
        
        session.stopTunnel()
    }
}
