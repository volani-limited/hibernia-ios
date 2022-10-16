//
//  PurchaseSubscriptionButtonView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 04/10/2022.
//

import SwiftUI

struct PurchaseSubscriptionButtonView: View {
    @EnvironmentObject var subscriptionService: IAPSubscriptionService
    
    var body: some View {
        VStack {
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
                        Text("Subscribe to Connect")
                            .font(.custom("Comfortaa", size: 16))
                            .bold()
                            .foregroundColor(.highlightStart)
                    }
                }
                .buttonStyle(NeumorphicButtonStyle())
                .disabled(subscriptionService.processing)
                if subscriptionService.processing {
                    ProgressView()
                }
            }
            
            Text("[Legal](https://hiberniavpn.com#legal)")
                .font(.custom("Comfortaa", size: 12))
                .foregroundColor(.highlightStart)
                .padding()
        }
    }
}

struct PurchaseSubscriptionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseSubscriptionButtonView()
    }
}
