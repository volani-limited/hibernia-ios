//
//  VPNControlStatusContainerView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 11/05/2024.
//

import SwiftUI

struct VPNControlStatusContainerView: View {
    @EnvironmentObject var vpnService: VPNService
    @EnvironmentObject var subscriptionService: IAPSubscriptionService
    
    @Binding var presentingSubscribeModalView: Bool
    
    private var statusProgress: Double {
        switch vpnService.status {
        case .requestingConfiguration:
            return 0.25
        case .connecting:
            return 0.25
        case .connected:
            return 1.0
        case .disconnecting:
            return 0.5
        case .disconnected:
            return 0.0
        }
    }
    
    private var statusColor: Color {
        switch vpnService.status {
        case .requestingConfiguration:
            return Color.vOrange
        case .connecting:
            return Color.vOrange
        case .connected:
            return Color.turquoise
        case .disconnecting:
            return Color.vRed
        case .disconnected:
            return Color.clear
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VPNConnectButtonView(presentingSubscribeModalView: $presentingSubscribeModalView)
                
                VStack {
                    ArcProgressView(progress: statusProgress, color: statusColor)
                        .frame(width: 155, height: 155)
                    
                    Text(vpnService.status.rawValue.capitalized).font(.custom("Comfortaa", size: 15))
                        .foregroundColor(.turquoise)
                        .padding(.top)
                    
                    if vpnService.status == .connected {
                        Text(vpnService.connectedTime).font(.custom("Comfortaa", size: 15))
                            .foregroundColor(.turquoise)
                            .padding(.bottom)
                    } else {
                        Spacer().frame(height: 15)
                    }
                }.offset(y: 45)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
