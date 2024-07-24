//
//  SettingsFooterView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 16/07/2024.
//

import SwiftUI

struct SettingsFooterView: View {
    @State private var presentingAcknowledgementsView: Bool = false
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            
            Button {
                openURL(URL(string: "https://status.hiberniavpn.com")!)
            } label: {
                Text("Infrastructure status")

                Image(systemName: "arrow.up.right.square.fill")
            }
            .font(.caption)
            .foregroundColor(Color.text)
            
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
        }
        .padding(.top, 10)
        .sheet(isPresented: $presentingAcknowledgementsView) {
            AcknowledgementsView()
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
