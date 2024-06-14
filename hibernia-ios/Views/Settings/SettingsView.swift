//
//  SettingsView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var subscriptionService: IAPSubscriptionService
    @EnvironmentObject var vpnService: VPNService
    
    @State private var presentingAcknowledgementsView: Bool = false

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
                    
                    VStack(alignment: .center) {
                        HStack(spacing: 12) {
                            Link("Terms & privacy", destination: URL(string: "https://hiberniavpn.com#legal")!) // Present legal information before subscribe action
                                .font(.caption)
                                .foregroundColor(.text)
                            
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.text)
                            
                            Button {
                                presentingAcknowledgementsView = true
                            } label: {
                                Text("Acknowledgements")
                                    .font(.caption)
                                    .foregroundColor(.text)
                            }
                        }
                        Text("HiberniaVPN v\(Bundle.main.releaseVersionNumber!) (\(Bundle.main.buildVersionNumber!)) © Volani Limited MMXXIV")
                            .font(.caption)
                            .foregroundColor(.text)
                    }.padding(.top, 10)
                }
                .padding(.top, 10)
                .padding()
            }
            .sheet(isPresented: $presentingAcknowledgementsView) {
                AcknowledgementsView()
            }
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

#Preview {
    SettingsView()
}
