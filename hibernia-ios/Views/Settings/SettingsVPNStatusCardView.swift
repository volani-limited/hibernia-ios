//
//  SettingsVPNStatusCardView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 14/06/2024.
//

import SwiftUI

struct SettingsVPNStatusCardView: View {
    @EnvironmentObject var vpnService: VPNService
    
    private var statusColor: Color {
        switch vpnService.status {
        case .requestingConfiguration:
            return Color.vOrange
        case .connecting:
            return Color.vOrange
        case .connected:
            return Color.green
        case .disconnecting:
            return Color.vOrange
        case .disconnected:
            return Color.red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("VPN STATUS")
                .font(.caption)
                .foregroundColor(.text)
                .padding(.bottom, 2)
            
            HStack(alignment: .center) {
                Text("Status")
                    .font(.custom("Comfortaa", size: 22))
                    .foregroundStyle(Color.text)
                
                Spacer()
                
                Image(systemName: "circle.fill").foregroundStyle(statusColor)
                Text(vpnService.status.rawValue)
                    .font(.custom("Comfortaa", size: 20))
                    .foregroundStyle(Color.titleText)
            }
            
            HStack {
                Text("Destination")
                    .font(.custom("Comfortaa", size: 22))
                    .foregroundStyle(Color.text)
                
                Spacer()
                
                Text(vpnService.destination.displayed)
                    .font(.custom("Comfortaa", size: 20))
                    .foregroundStyle(Color.titleText)
            }
            
            if vpnService.status == .connected {
                HStack {
                    Text("Hostname")
                        .font(.custom("Comfortaa", size: 22))
                        .foregroundStyle(Color.text)
                    
                    Spacer()
                    
                    Text(vpnService.destination.hostname)
                        .font(.custom("Comfortaa", size: 15))
                        .foregroundStyle(Color.titleText)
                }
                
                HStack {
                    Text("IP address")
                        .font(.custom("Comfortaa", size: 22))
                        .foregroundStyle(Color.text)
                    
                    Spacer()
                    
                    if let ip = vpnService.vpnIP {
                        Text(ip)
                            .font(.custom("Comfortaa", size: 15))
                            .foregroundStyle(Color.titleText)
                    } else {
                        Text("Could not determine IP")
                            .font(.custom("Comfortaa", size: 15))
                            .foregroundStyle(Color.titleText)
                    }
                    
                }
                
                HStack {
                    Text("Connected time")
                        .font(.custom("Comfortaa", size: 22))
                        .foregroundStyle(Color.text)
                    
                    Spacer()
                    
                    Text(vpnService.connectedTime)
                        .font(.custom("Comfortaa", size: 20))
                        .foregroundStyle(Color.titleText)
                }
                
                
            }
        }
        .padding()
        .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)))
    }
}

#Preview {
    SettingsVPNStatusCardView()
}
