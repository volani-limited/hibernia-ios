//
//  SettingsView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI
import FirebaseRemoteConfig

struct SettingsView: View {
    @EnvironmentObject var vpnService: VPNService
    
    @RemoteConfigProperty(key: "presentsExtraSettings", fallback: true) var presentsExtraSettings: Bool

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
                    
                    if presentsExtraSettings {
                        SettingsExtraSettingsCardView()
                    }
                    
                    SettingsFooterView()
                }
                .padding(.top, 10)
                .padding()
            }
        }
    }
}
