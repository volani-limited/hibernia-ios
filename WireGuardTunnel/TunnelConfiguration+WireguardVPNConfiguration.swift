//
//  TunnelConfiguration+WireguardVPNConfiguration.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 27/03/2025.
//

import Foundation
import WireGuardKit
import Network

extension TunnelConfiguration { // TODO: more granular errors?
    convenience init(from configuration: WireguardVPNConfiguration) throws {
        guard let privateKeyString = configuration.privateKey, let privateKey = PrivateKey(base64Key: privateKeyString) else {
            throw WireguardPacketTunnelProviderError.invalidProviderConfiguration
        }
        
        var interface = InterfaceConfiguration(privateKey: privateKey)
        
        guard let address = IPAddressRange(from: configuration.address) else {
            throw WireguardPacketTunnelProviderError.invalidProviderConfiguration
        }
        
        interface.addresses.append(address)
        
        guard let dns = DNSServer(from: configuration.dns) else {
            throw WireguardPacketTunnelProviderError.invalidProviderConfiguration
        }
        
        interface.dns.append(dns)
        
        guard let publicKey = PublicKey(base64Key: configuration.publicKey) else {
            throw WireguardPacketTunnelProviderError.invalidProviderConfiguration
        }
        
        var peer = PeerConfiguration(publicKey: publicKey)
        
        guard let endpoint = Endpoint(from: configuration.endpoint) else {
            throw WireguardPacketTunnelProviderError.invalidProviderConfiguration
        }
        
        peer.endpoint = endpoint
        
        self.init(name: "HiberniaVPN Dedicated", interface: interface, peers: [peer])
    }
}
