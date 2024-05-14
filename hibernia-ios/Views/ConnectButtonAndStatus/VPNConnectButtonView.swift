//
//  VPNConnectButtonView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

import SwiftUI
import TunnelKitCore
import TunnelKitManager
import TunnelKitOpenVPN

struct VPNConnectButtonView: View {
    @EnvironmentObject var vpnService: VPNService
    @EnvironmentObject var subscriptionService: IAPSubscriptionService

    @Binding var presentingSubscribeModalView: Bool
    
    @State private var vpnServiceTask: Task<Void, Error>?
    
    var body: some View {
        Button {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.impactOccurred()
            
            if subscriptionService.originalTransactionID == nil {
                presentingSubscribeModalView = true
            } else {
                switch vpnService.status { // Define button action based on VPN status
                case .disconnected:
                    vpnServiceTask = Task {
                        await vpnService.connect(transactionID: subscriptionService.originalTransactionID!)
                    }
                    
                case .connected:
                    vpnServiceTask = Task {
                        vpnService.disconnect()
                    }
                case .requestingConfiguration, .connecting:
                    vpnServiceTask?.cancel()
                    
                    vpnServiceTask = Task {
                        vpnService.disconnect()
                    }
                case .disconnecting:
                    break
                }
            }
        } label: {
            Image(systemName: "power")
                .font(.system(size: 55, weight: .heavy))
                .foregroundColor(vpnService.status == .connected ? .white : .turquoise)
                .padding(30)
        }
        .buttonStyle(NeumorphicMainButtonStyle(isProcessing: (vpnService.status != .connected) == (vpnService.status != .disconnected), isDepressed: vpnService.status == .connected))
        .disabled(vpnService.status == .disconnecting)
    }
}
