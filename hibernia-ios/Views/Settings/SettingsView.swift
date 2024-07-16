//
//  SettingsView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vpnService: VPNService

    var body: some View {
        VStack {
            Text("Settings")
                .fontWeight(.black)
                .font(.custom("Comfortaa", size: 40))
                .foregroundColor(.titleText)
                .padding()
            
            ScrollView {
                VStack(spacing: 15) {
                    SettingsSubscriptionCardView()
                    
                    SettingsVPNStatusCardView()
                    
                    SettingsVPNSettingsCardView()
                    
                    SettingsFooterView()
                }
                .padding(.top, 10)
                .padding()
            }
        }
    }
}
