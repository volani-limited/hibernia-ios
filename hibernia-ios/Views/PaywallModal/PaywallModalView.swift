//
//  SubscribeModalView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 12/05/2024.
//

import SwiftUI
import RevenueCat

struct PaywallModalView: View {
    @EnvironmentObject var subscriptionService: RevenueCatSubscriptionService
    @Environment(\.dismiss) var dismiss
    
    @State private var offering: Offering?
    @State private var paywallInformation: RevenueCatSubscriptionService.PaywallInformation?
    
    @State private var processingLoadSubscriptionProduct: Bool = true
    @State private var presentingProductLoadError: Bool = false
    
    @State private var processingStoreOperation: Bool = false
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            if processingLoadSubscriptionProduct {
                ProgressView()
                    .task {
                        do {
                            offering = try await subscriptionService.getOfferings().current
                            paywallInformation = RevenueCatSubscriptionService.getPaywallInformation(for: offering!)
                            
                            processingLoadSubscriptionProduct = false
                        } catch {
                            print(error.localizedDescription)
                            presentingProductLoadError = true
                        }
                    }
                    .alert("Could not load subscription offerings, check your connection.", isPresented: $presentingProductLoadError) {
                        Button("Ok") {
                            dismiss()
                        }
                    }
            } else {
                VStack {
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
                    
                    PaywallInformationView(paywallInformation: paywallInformation!, offering: offering!)
                        .offset(y: -40
                        )
                    
                    Spacer()
                    
                    PaywallPackgeOptionsSubscribeView(packages: offering!.availablePackages, selectedPackage: offering!.availablePackages.first!, processingSubscribe: $processingStoreOperation)
                    
                    PaywallFooterView(processingRestore: $processingStoreOperation)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    PaywallModalView()
}
