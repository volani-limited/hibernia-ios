//
//  PurchaseSubscriptionButtonView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 04/10/2022.
//

import SwiftUI

struct PurchaseSubscriptionButtonView: View {
    @State private var isPressed = false
    var body: some View {
        Button {
            isPressed = true
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
