//
//  File.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 16/11/2022.
//

import SwiftUI

struct ConnectionToolbar: View {
    @EnvironmentObject var vpnService: VPNService
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Always-on")
                        .font(.custom("Comfortaa", size: 16))
                        .foregroundColor(.highlightStart)
                    Text("Automatically reconnect if the connection is lost")
                        .font(.custom("Comfortaa", size: 11))
                        .foregroundColor(.highlightStart)
                    
                }
                Spacer()
                Button {
                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    feedbackGenerator.impactOccurred()
                    
                    vpnService.keepAlive.toggle()
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(vpnService.keepAlive ? .white : .highlightStart)
                        .padding()
                }
                .buttonStyle(MainButtonStyle(isProcessing: false, isDepressed: vpnService.keepAlive))
                .disabled(vpnService.status != .disconnected)
            }
            Divider().padding()
            HStack {
                VStack(alignment: .leading) {
                    Text("Kill switch")
                        .font(.custom("Comfortaa", size: 16))
                        .foregroundColor(.highlightStart)
                    Text("Prevent insecure connections if VPN connection  islost")
                        .font(.custom("Comfortaa", size: 11))
                        .foregroundColor(.highlightStart)
                    
                }
                Spacer()
                Button {
                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    feedbackGenerator.impactOccurred()
                    
                    vpnService.killSwitch.toggle()
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(vpnService.killSwitch ? .white : .highlightStart)
                        .padding()
                }
                .buttonStyle(MainButtonStyle(isProcessing: false, isDepressed: vpnService.killSwitch))
                .disabled(vpnService.status != .disconnected)
            }
        }.padding()
            .background(
                NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 10))
            )
        
    }
}
