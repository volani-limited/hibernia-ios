//
//  OpenVPNController.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 28/02/2025.
//

import Foundation

import TunnelKitCore
import TunnelKitManager
import TunnelKitOpenVPN

import NetworkExtension

class OpenVPNController {
    static let tunnelIdentifier = "uk.co.volani.hibernia-ios.OpenVPNTunnel" // Define identifiers

    private var vpn: NetworkExtensionVPN
    
    init() {
        vpn = NetworkExtensionVPN()
    }
    
    public func prepare() async {
        await vpn.prepare()
    }
    
    public func connect(with configuration: NetworkExtensionConfiguration, extras: NetworkExtensionExtra) async throws {
        try await vpn.reconnect(OpenVPNController.tunnelIdentifier, configuration: configuration, extra: extras, after: .milliseconds(100))
    }
    
    public func disconnnect() async {
        await vpn.disconnect()
    }
}
