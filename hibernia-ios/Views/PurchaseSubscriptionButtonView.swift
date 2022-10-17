//
//  PurchaseSubscriptionButtonView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 04/10/2022.
//

import SwiftUI

struct PurchaseSubscriptionButtonView: View {
    @EnvironmentObject var subscriptionService: IAPSubscriptionService
    @Environment(\.isEnabled) var isEnabled
    
    var body: some View {
        VStack() {
            ZStack {
                Button {
                    if subscriptionService.processing != true {
                        subscriptionService.processing = true
                        Task {
                            await subscriptionService.setSubscriptionProduct()
                            await subscriptionService.subscribe()
                        }
                    }
                } label: {
                    HStack(alignment: .bottom) {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.highlightStart)
                        Text("Subscribe to Hibernia")
                            .font(.custom("Comfortaa", size: 16))
                            .bold()
                            .foregroundColor(.highlightStart)
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(isProcessing: subscriptionService.processing))
                .disabled(subscriptionService.processing)
                if subscriptionService.processing {
                    ProgressView()
                }
            }
            VStack(spacing: 5) {
                Text("Auto-renews for " + (subscriptionService.subscriptionProduct?.displayPrice ?? "unknown") + " per month\nafter a 3 day trial until cancelled.")
                    .font(.custom("Comfortaa", size: 12))
                    .foregroundColor(.highlightEnd)
                Button {
                    Task {
                        await subscriptionService.restorePurchases()
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.custom("Comfortaa", size: 14))
                        .foregroundColor(.highlightStart)
                }
                Link("Terms of service and privacy policy", destination: URL(string: "https://hiberniavpn.com#legal")!)
                    .font(.custom("Comfortaa", size: 12))
                    .foregroundColor(.highlightStart)
            }.padding(.top, 10)
        }
        .overlay(!isEnabled ? ProgressView() : nil)
    }
}

struct PurchaseSubscriptionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseSubscriptionButtonView()
    }
}
