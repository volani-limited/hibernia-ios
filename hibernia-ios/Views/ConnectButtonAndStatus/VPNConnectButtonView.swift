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
    @EnvironmentObject var subscriptionService: RevenueCatSubscriptionService

    @State var presentingSubscribeModalView: Bool = false
    
    @State private var vpnServiceTask: Task<Void, Error>?
    
    @State private var presentingVPNConnectionError: Bool = false

    var body: some View {
        Button {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.impactOccurred()
            
            if subscriptionService.subscriptionStatus == .notSubscribed {
                presentingSubscribeModalView = true
            } else {
                switch vpnService.status { // Define button action based on VPN status
                case .disconnected:
                    vpnServiceTask = Task {
                        do {
                            try await vpnService.connect(appUserId: subscriptionService.customerInfo!.id)
                        } catch {
                            print("Error connecting to VPN: \(error.localizedDescription)")
                            presentingVPNConnectionError = true
                        }
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
                .foregroundColor(vpnService.status == .connected ? Color.lightShadow : .turquoise)
                .shadow(color: vpnService.status == .connected ? Color.lightShadow : .turquoise, radius: 15)
                .padding(30)
        }
        .buttonStyle(NeumorphicMainButtonStyle(isProcessing: (vpnService.status != .connected) == (vpnService.status != .disconnected), isDepressed: vpnService.status == .connected))
        .disabled(vpnService.status == .disconnecting)
        .alert("Could not connect to VPN. Check your connection.", isPresented: $presentingVPNConnectionError) {
            Button("Ok") { }
        }
        .sheet(isPresented: $presentingSubscribeModalView) {
            PaywallModalView()
        }
    }
}
