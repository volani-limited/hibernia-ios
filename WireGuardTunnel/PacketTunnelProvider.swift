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
        return WireGuardAdapter(with: self) {_,_ in // TODO: tidy this up
            
        }
    }()
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        notifyStatusChange(status: .connecting)
        
        guard let protocolConfiguration = self.protocolConfiguration as? NETunnelProviderProtocol,
              let providerConfiguration = protocolConfiguration.providerConfiguration,
              let providerConfigurationData = try? JSONSerialization.data(withJSONObject: providerConfiguration, options: []),
              let wireguardConfiguration = try? JSONDecoder().decode(WireguardVPNConfiguration.self, from: providerConfigurationData),
              let tunnelConfiguration = try? TunnelConfiguration(from: wireguardConfiguration) else {
            
            notifyError(error: WireguardPacketTunnelProviderError.invalidProviderConfiguration)
            notifyStatusChange(status: .disconnected)
        }
        
        adapter.start(tunnelConfiguration: tunnelConfiguration) { [weak self] adapterError in
            if let adapterError = adapterError {
                self?.notifyError(error: WireguardPacketTunnelProviderError.invalidProviderConfiguration)
                self?.notifyStatusChange(status: .disconnected)
            } else {
                self?.notifyStatusChange(status: .connected)
            }
            completionHandler(adapterError)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        notifyStatusChange(status: .disconnecting)
        
        adapter.stop() { [weak self] error in
            if let error = error {
                self?.notifyError(error: error)
            } else {
                self?.notifyStatusChange(status: .disconnected)
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
}
