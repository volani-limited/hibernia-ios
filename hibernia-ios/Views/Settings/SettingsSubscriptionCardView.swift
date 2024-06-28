//
//  SettingsSubscriptionCardView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 11/06/2024.
//

import SwiftUI

struct SettingsSubscriptionCardView: View {
    @EnvironmentObject var subscriptionService: RevenueCatSubscriptionService
    
    @State private var presentingSubscribeModal: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("SUBSCRIPTION")
                .font(.caption)
                .foregroundColor(.text)
                .padding(.bottom, 2)
            
            HStack(spacing: 5) {
                Text("Status")
                    .font(.custom("Comfortaa", size: 22))
                    .foregroundStyle(Color.text)
                
                Spacer()
                
                if !subscriptionService.entitledToPremium {
                    Image(systemName: "circle.fill").foregroundStyle(.red)
                    Text("Not subscribed")
                        .font(.custom("Comfortaa", size: 20))
                        .foregroundStyle(Color.titleText)
                } else {
                    Image(systemName: "circle.fill").foregroundStyle(.green)
                    Text("Subscribed")
                        .font(.custom("Comfortaa", size: 20))
                        .foregroundStyle(Color.titleText)
                }
            }
            
            if !subscriptionService.entitledToPremium {
                HStack {
                    Spacer()
                    
                    Button {
                        presentingSubscribeModal = true
                    } label: {
                        Text("Subscribe now")
                            .font(.custom("Comfortaa", size: 15))
                            .foregroundStyle(Color.titleText)
                            .padding()
                    }
                    .buttonStyle(NeumorphicButtonStyle(shape: RoundedRectangle(cornerRadius: 25)))
                    .padding(.top, 4)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)))
        .sheet(isPresented: $presentingSubscribeModal) {
            SubscribeModalView()
        }
    }
}

#Preview {
    SettingsSubscriptionCardView()
}
