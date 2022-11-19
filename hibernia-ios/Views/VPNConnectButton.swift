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
    @EnvironmentObject var vpnService: VPNService
    @EnvironmentObject var subscriptionService: IAPSubscriptionService

    @State private var vpnServiceTask: Task<Void, Error>?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Button {
                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    feedbackGenerator.impactOccurred()
                    
                    switch vpnService.status {
                    case .disconnected:
                        vpnService.status = .connecting
                        vpnServiceTask = Task {
                            await vpnService.connect(transactionID: subscriptionService.originalTransactionID!)
                        }
                        
                    case .connected:
                        vpnServiceTask = Task {
                            vpnService.disconnect()
                        }
                    case .connecting:
                        vpnServiceTask?.cancel()

                        vpnServiceTask = Task {
                            vpnService.disconnect()
                        }
                    case .disconnecting:
                        break
                    }
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 55, weight: .heavy))
                        .foregroundColor(vpnService.status == .connected ? .white : .highlightStart)
                        .padding(30)
                }
                .buttonStyle(MainButtonStyle(isProcessing: (vpnService.status != .connected) == (vpnService.status != .disconnected), isDepressed: vpnService.status == .connected))
                .disabled(vpnService.status == .disconnecting)
                
                Text(vpnService.status.rawValue.capitalized).font(.custom("Comfortaa", size: 15))
                    .foregroundColor(.highlightStart)
                    .padding(.top)
                
                if vpnService.status == .connected {
                    Text(vpnService.connectedTime).font(.custom("Comfortaa", size: 15))
                        .foregroundColor(.highlightStart)
                        .padding(.bottom)
                } else {
                    Spacer().frame(height: 15)
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                Task {
                    await vpnService.prepare()
                }
            }
        }
    }
    
}

struct VPNConnectView_Previews: PreviewProvider {
    @State var isOpen = false
    static var previews: some View {
        VPNConnectButton().scaleEffect(1)
    }
}

