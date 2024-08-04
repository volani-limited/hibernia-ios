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
    @State private var presentingManageSubscriptionModal: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("SUBSCRIPTION")
                .font(.caption)
                .foregroundColor(.text)
                .padding(.bottom, 2)
            
            HStack(spacing: 5) {
                Text("Status")
                    .font(.custom("Comfortaa", size: 22))
                    .foregroundStyle(Color.text)
                
                Spacer()
                
                Image(systemName: "circle.fill").foregroundStyle(subscriptionService.subscriptionStatus == .notSubscribed ? .red : .green)
                Text(subscriptionService.subscriptionStatus.statusDisplay)
                    .font(.custom("Comfortaa", size: 20))
                    .foregroundStyle(Color.titleText)
            }
            
            if let expiryDate = subscriptionService.subscriptionExpiryDate {
                HStack(spacing: 5) {
                    Text("Expires")
                        .font(.custom("Comfortaa", size: 22))
                        .foregroundStyle(Color.text)
                    
                    Spacer()
                    
                    Text(expiryDate.formatted(date: .numeric, time: .omitted))
                        .font(.custom("Comfortaa", size: 20))
                        .foregroundStyle(Color.titleText)
                }
            }
            
            HStack {
                Spacer()
                
                if subscriptionService.subscriptionStatus == .notSubscribed {
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
                } else if subscriptionService.subscriptionStatus == .standardSubscription {
                    Button {
                        presentingSubscribeModal = true
                    } label: {
                        Text("Upgrade")
                            .font(.custom("Comfortaa", size: 15))
                            .foregroundStyle(Color.titleText)
                            .padding()
                    }
                    .buttonStyle(NeumorphicButtonStyle(shape: RoundedRectangle(cornerRadius: 25)))
                    .padding(.top, 4)
                }
                
                if subscriptionService.subscriptionStatus == .familyShareable || subscriptionService.subscriptionStatus == .standardSubscription {
                    Button {
                        presentingManageSubscriptionModal = true
                    } label: {
                        Text("Manage")
                            .font(.custom("Comfortaa", size: 15))
                            .foregroundStyle(Color.titleText)
                            .padding()
                    }
                    .buttonStyle(NeumorphicButtonStyle(shape: RoundedRectangle(cornerRadius: 25)))
                    .padding(.top, 4)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)))
        .sheet(isPresented: $presentingSubscribeModal) {
            PaywallModalView()
        }
        .manageSubscriptionsSheet(isPresented: $presentingManageSubscriptionModal)
    }
}

#Preview {
    SettingsSubscriptionCardView()
}
