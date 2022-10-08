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
        ZStack {
            Button {
                Task {
                    if subscriptionService.processing != true {
                        await subscriptionService.subscribe()
                    }
                }
            } label: {
                HStack(alignment: .bottom) {
                    Image(systemName: "wand.and.stars")
                        .bold()
                        .foregroundColor(.highlightStart)
                    Text("Subscribe to Connect").font(.custom("Comfortaa", size: 16))
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
    }
}

struct PurchaseSubscriptionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseSubscriptionButtonView()
    }
}
