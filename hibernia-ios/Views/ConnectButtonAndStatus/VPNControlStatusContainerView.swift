//
//  VPNControlStatusContainerView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 11/05/2024.
//

import SwiftUI
import FirebaseRemoteConfig

struct VPNControlStatusContainerView: View {
    @RemoteConfigProperty(key: "maxConnectionDuration", fallback: "") var maximumDuration: String
    
    @EnvironmentObject var vpnService: VPNService
    
    private var statusProgress: Double {
        switch vpnService.status {
        case .requestingConfiguration:
            return 0.25
        case .connecting:
            return 0.5
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
            return Color.vOrange
        case .disconnected:
            return Color.clear
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VPNConnectButtonView()
                
                VStack {
                    ArcProgressView(progress: statusProgress, color: statusColor)
                        .frame(width: 155, height: 155)
                    
                    Text(vpnService.status.rawValue)
                        .font(.custom("Comfortaa", size: 18, relativeTo: .title))
                        .bold()
                        .foregroundColor(.titleText)
                        .padding(.top)
                    
                    if maximumDuration.isEmpty {
                        Text(vpnService.connectedTime)
                            .font(.custom("Comfortaa", size: 15, relativeTo: .title))
                            .foregroundColor(.text)
                            .padding(.bottom)
                            .opacity(vpnService.status == .connected ? 1 : 0)
                    } else {
                        Text(vpnService.connectedTime + " / " + maximumDuration)
                            .font(.custom("Comfortaa", size: 15, relativeTo: .title))
                            .foregroundColor(.text)
                            .padding(.bottom)
                            .opacity(vpnService.status == .connected ? 1 : 0)
                    }
                    
                }
                .offset(y: 45)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
