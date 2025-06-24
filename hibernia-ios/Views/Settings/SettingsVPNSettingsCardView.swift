//
//  SettingsVPNSettingsCardView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 11/06/2024.
//

import SwiftUI

struct SettingsVPNSettingsCardView: View {
    @EnvironmentObject var vpnService: VPNService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("VPN SETTINGS")
                .font(.caption)
                .foregroundColor(.text)
                .padding(.bottom, 2)
            
            HStack {
                Text("Protocol")
                    .font(.custom("Comfortaa", size: 22, relativeTo: .largeTitle))
                    .foregroundStyle(Color.text)
                
                Spacer()
                
                Text("OpenVPN")
                    .font(.custom("Comfortaa", size: 20, relativeTo: .largeTitle))
                    .foregroundStyle(Color.titleText)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Always-on")
                        .font(.custom("Comfortaa", size: 22, relativeTo: .largeTitle))
                        .foregroundStyle(Color.text)
                    Text("Reconnect if the connection is lost")
                        .font(.custom("Comfortaa", size: 15, relativeTo: .largeTitle))
                        .foregroundStyle(Color.text)
                }
                
                Spacer()

                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    vpnService.keepAlive.toggle()
                } label: {
                    Image(systemName: vpnService.keepAlive ? "checkmark.circle" : "circle")
                        .foregroundStyle(vpnService.keepAlive ? Color.turquoise : Color.text)
                        .shadow(color: vpnService.keepAlive ? Color.turquoise : Color.text, radius: 4)
                        .padding(5)
                }
                .buttonStyle(NeumorphicButtonStyle(shape: Circle(), isHighlighted: vpnService.keepAlive))
                .opacity(vpnService.status == .connected ? 0.5 : 1 )
                .disabled(vpnService.status == .connected)
                .dynamicTypeSize(.large)
            }
        }
        .padding()
        .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)))
    }
}

#Preview {
    SettingsVPNSettingsCardView()
}
