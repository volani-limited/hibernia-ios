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
        Button {
            Task {
                if subscriptionService.processing != true {
                    try? await subscriptionService.subscribe()
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
        }.buttonStyle(NeumorphicButtonStyle())
    }
}

struct PurchaseSubscriptionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseSubscriptionButtonView()
    }
}
