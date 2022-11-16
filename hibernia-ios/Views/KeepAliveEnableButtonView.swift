//
//  File.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 16/11/2022.
//

import SwiftUI

struct KeepAliveEnableButtonView: View {
    @EnvironmentObject var vpnService: VPNService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Keep alive")
                    .font(.custom("Comfortaa", size: 13))
                    .foregroundColor(.highlightStart)
                Text("Automatically reconnects if the VPN connection is lost")
                    .font(.custom("Comfortaa", size: 9))
                    .foregroundColor(.highlightStart)
            }
            Spacer()
            Button {
                vpnService.keepAlive.toggle()
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.highlightStart)
                    .padding()
            }
            .buttonStyle(MainButtonStyle(isProcessing: false, isDepressed: vpnService.keepAlive))
        }
        .padding()
        .background(
            NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 10))
        )
    }
}
