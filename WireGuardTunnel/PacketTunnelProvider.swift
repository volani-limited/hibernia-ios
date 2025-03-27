//
//  PacketTunnelProvider.swift
//  WireGuardTunnel
//
//  Created by Oliver Bevan on 25/02/2025.
//

import NetworkExtension
import WireGuardKit

import TunnelKitManager

enum WireguardPacketTunnelProviderError: String, Error {
    case invalidProviderConfiguration = "The provided provider configuration is invalid or missing."
}

class PacketTunnelProvider: NEPacketTunnelProvider {

    private lazy var adapter: WireGuardAdapter = {
        return WireGuardAdapter(with: self)
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        notifyStatusChange(status: .connecting)
        
        guard let protocolConfiguration = self.protocolConfiguration as? NETunnelProviderProtocol, let providerConfiguration = protocolConfiguration.providerConfiguration, let wireguardConfigurationDict = providerConfiguration else {
            notifyError(error: WireguardPacketTunnelProviderError.invalidProviderConfiguration)
        }
        
        let host
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        notifyStatusChange(status: .disconnecting)
        
        adapter.stop() { [weak self] error in
            if let error = error {
                self?.notifyError(error: error)
            } else {
                notifyStatusChange(status: .disconnected)
            }
        }
        
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    private func notifyStatusChange(status: VPNStatus) { // Using Tunnelkit VPNNotification to ensure compatibility with existing observers. This may cause issues
        var notification = Notification(name: VPNNotification.didChangeStatus)
        notification.vpnStatus = status // TODO: Should probably send additional details but this is all that is necessary
        
        NotificationCenter.default.post(notification)
    }
    
    private func notifyError(error: Error) {
        var notification = Notification(name: VPNNotification.didFail)
        notification.vpnError = error
        
        NotificationCenter.default.post(notification)
    }
    
    private func getTunnelConfiguration(from configuration: [String: Any]) throws -> TunnelConfiguration {
        
        
        let peerConfiguration = PeerConfiguration(publicKey: configuration["public_key"] as! String)
    }
}
