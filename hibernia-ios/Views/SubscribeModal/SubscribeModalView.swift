//
//  SubscribeModalView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 12/05/2024.
//

import SwiftUI
import RevenueCat

struct SubscribeModalView: View {
    @EnvironmentObject var subscriptionService: RevenueCatSubscriptionService
    
    @Environment(\.dismiss) var dismiss
    
    @State private var offering: Offering?
    
    @State private var processingLoadSubscriptionProduct: Bool = true
    @State private var presentingProductLoadError: Bool = false
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            if processingLoadSubscriptionProduct {
                ProgressView()
                    .task {
                        do {
                            offering = try await subscriptionService.getOfferings().current
                            
                            processingLoadSubscriptionProduct = false
                        } catch {
                            print(error.localizedDescription) // TODO: Store error and present details contextually? Will be updated alongside UI and IAP service
                            presentingProductLoadError = true
                        }
                    }
                    .alert("Could not load subscription offerings, check your connection.", isPresented: $presentingProductLoadError) {
                        Button("Ok") {
                            dismiss()
                        }
                    }
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.text)
                                .padding()
                        }
                        .buttonStyle(NeumorphicButtonStyle(shape: Circle()))
                        .padding()
                        
                        Spacer()
                    }
                    
                    Text("The world's simplest VPN\nfrom just " + offering!.availablePackages[0].localizedPriceString + " per month") //TODO: configure with offering metadata
                        .bold()
                        .font(.title)
                        .foregroundColor(.turquoise)
                        .padding(.leading)
                    Text("That's " + offering!.availablePackages[0].localizedPriceString + " each month after a 3-day free trial. Cancel anytime.")
                        .foregroundColor(.text)
                        .padding(.leading)

                    Spacer()
                    
                    SubscriptionOptionsSubscribeView(packages: offering!.availablePackages, selectedPackage: offering!.availablePackages.first!)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    SubscribeModalView()
}
