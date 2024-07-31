//
//  PaywallFooterView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 16/07/2024.
//

import SwiftUI
import FirebaseRemoteConfig

struct PaywallFooterView: View {
    @EnvironmentObject var subscriptionService: RevenueCatSubscriptionService
    @Environment(\.dismiss) var dismiss
    
    @RemoteConfigProperty(key: "displaysRedeemKey", fallback: false) var displaysRedeemKey: Bool
    
    @Binding var processingRestore: Bool
    
    @State private var presentingRestoreError: Bool = false
    @State private var presentingRestoreSuccess: Bool = false
    
    @State private var presentingRedeemLicenseKeyModal: Bool = false
    @State private var presentingTermsModal: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    processingRestore = true
                    do {
                        try await subscriptionService.restorePurchases()
                        presentingRestoreSuccess = true
                    } catch {
                        print(error.localizedDescription)
                        processingRestore = false
                        presentingRestoreError = true
                    }
                }
            } label: {
                Text("Restore purchases")
                    .font(.caption)
                    .foregroundColor(.text)
            }
            .disabled(processingRestore)
            .alert("Could not restore purchases, check your connection.", isPresented: $presentingRestoreError) {
                Button("Ok") { }
            }
            .alert("Purchases restored successfully.", isPresented: $presentingRestoreSuccess) {
                Button("Ok") { dismiss() }
            }
            
            Text("•")
                .font(.caption)
                .foregroundColor(.text)
            
            Button {
                presentingTermsModal = true
            } label: {
                Text("Terms & privacy")// Present legal information before subscribe action
                    .font(.caption)
                    .foregroundColor(.text)
            }
            
            if displaysRedeemKey {
                Text("•")
                    .font(.caption)
                    .foregroundColor(.text)
                
                Button {
                    presentingRedeemLicenseKeyModal = true
                } label: {
                    Text("Redeem license key")
                        .font(.caption)
                        .foregroundColor(.text)
                }
            }
        }
        .sheet(isPresented: $presentingRedeemLicenseKeyModal) {
            RedeemLicenseKeyModalView(parentDismissAction: dismiss)
        }
        .sheet(isPresented: $presentingTermsModal) {
            SafariWebView(url: URL(string: "https://hiberniavpn.com#legal")!)
        }
    }
}
