//
//  VPNConnectview.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

import SwiftUI
import TunnelKitCore
import TunnelKitManager
import TunnelKitOpenVPN

struct VPNConnectButton: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var vpnService: VPNService
    @EnvironmentObject var subscriptionService: IAPSubscriptionService

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Button {
                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    feedbackGenerator.impactOccurred()
                    switch vpnService.status {
                    case .disconnected:
                        vpnService.status = .connecting
                        Task {
                            if let authKey = await authService.getAuthToken() {
                                await vpnService.connect(transactionID: subscriptionService.originalTransactionID!, authKey: authKey)
                            }
                        }
                        
                    case .connected:
                        Task {
                            vpnService.disconnect()
                        }
                    case .connecting, .disconnecting:
                        break
                    }
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 55, weight: .heavy))
                        .foregroundColor(.highlightStart)
                }
                .buttonStyle(MainButtonStyle(isProcessing: (vpnService.status != .connected) == (vpnService.status != .disconnected), isDepressed: vpnService.status == .connected))
                .disabled(vpnService.status == .connecting || vpnService.status == .disconnecting) // Won't gray out due to condition on opacity change in ButtonStyle
                 
                Text(vpnService.status.rawValue.capitalized).font(.custom("Comfortaa", size: 15))
                    .foregroundColor(.highlightStart)
                    .padding()
                
                .onAppear {
                    Task {
                        await vpnService.prepare()
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
}

struct VPNConnectView_Previews: PreviewProvider {
    @State var isOpen = false
    static var previews: some View {
        VPNConnectButton().scaleEffect(1)
    }
}

