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
                    Task {
                        if subscriptionService.processing != true {
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
            
            Text("[Remember, HiberniaVPN collects no data.](https://hiberniavpn.com)")
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
