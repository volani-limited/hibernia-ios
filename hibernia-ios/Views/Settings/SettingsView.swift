//
//  SettingsView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI
import FirebaseRemoteConfig

struct SettingsView: View {
    @EnvironmentObject var subscriptionService: RevenueCatSubscriptionService

    @EnvironmentObject var vpnService: VPNService
    
    @RemoteConfigProperty(key: "presentsExtraSettings", fallback: true) var presentsExtraSettings: Bool
    @RemoteConfigProperty(key: "allowsDebugInfoAlert", fallback: true) var allowsDebugInfoAlert: Bool

    @State private var presentingDebugInfoAlert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Settings")
                    .fontWeight(.black)
                    .font(.custom("Comfortaa", fixedSize: 40))
                    .foregroundColor(.titleText)
                    .padding()
                    .onTapGesture {
                        if allowsDebugInfoAlert {
                            presentingDebugInfoAlert = true
                        }
                    }
                
                ScrollView {
                    VStack(spacing: 15) {
                        SettingsSubscriptionCardView()
                        
                        SettingsVPNStatusCardView()
                        
                        SettingsVPNSettingsCardView()
                        
                        if presentsExtraSettings {
                            SettingsExtraSettingsCardView()
                        }
                        
                        SettingsFooterView()
                            .dynamicTypeSize(.accessibility2)
                       
                        Spacer()
                            .frame(minHeight: geometry.size.height * 0.15)
                    }
                    .padding(.top, 10)
                    .padding()
                }
            }
            .alert("Debug information", isPresented: $presentingDebugInfoAlert) {
                Button("Copy") {
                    if let id = subscriptionService.customerInfo?.id {
                        UIPasteboard.general.string = id
                    }
                }
                Button("Close") { }
                    .keyboardShortcut(.defaultAction)
            } message: {
                Text("Made with ❤️ in the South of England" + "\nApp User ID: " + (subscriptionService.appUserId))
            }
        }
    }
}
