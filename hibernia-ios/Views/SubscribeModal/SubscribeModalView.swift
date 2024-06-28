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
    
    @State private var selectedPackageIndex: Int = 0
    
    @State private var processingLoadSubscriptionProduct: Bool = true
    @State private var presentingProductLoadError: Bool = false
    
    @State private var processingSubscribe: Bool = false
    @State private var presentingSubscribeError: Bool = false
    
    @State private var processingRestore: Bool = false
    @State private var presentingRestoreError: Bool = false
    
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
                    .alert("Could not load subscription product, check your connection.", isPresented: $presentingProductLoadError) {
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
                    
                    
                    Text("The world's simplest VPN\nfrom just " + offering!.availablePackages[0].localizedPriceString + " per month")
                        .bold()
                        .font(.title)
                        .foregroundColor(.turquoise)
                        .padding(.leading)
                    Text("That's " + offering!.availablePackages[0].localizedPriceString + " each month after a 3-day free trial. Cancel anytime.")
                        .foregroundColor(.text)
                        .padding(.leading)

                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            VStack {
                                ForEach((0...offering!.availablePackages.count - 1), id: \.self) { index in
                                    Button {
                                        self.selectedPackageIndex = index
                                    } label: {
                                        Text(offering!.availablePackages[index].storeProduct.localizedTitle + " for " + offering!.availablePackages[index].localizedPriceString)
                                            .bold()
                                            .font(.custom("Comfortaa", size: 18))
                                            .foregroundStyle(Color.text)
                                            .padding()
                                    }.buttonStyle(NeumorphicButtonStyle(shape: RoundedRectangle(cornerRadius: 25), isHighlighted: index == selectedPackageIndex))
                                }
                            }
                            
                            
                            VStack(spacing: 20) {
                                Button {
                                    processingSubscribe = true
                                    Task {
                                        do {
                                            try await subscriptionService.purchase(package: offering!.availablePackages[selectedPackageIndex])
                                            dismiss()
                                        } catch {
                                            print(error.localizedDescription)
                                            processingSubscribe = false
                                            presentingSubscribeError = true
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        Text("Subscribe now for " + offering!.availablePackages[selectedPackageIndex].localizedPriceString)
                                            .bold()
                                            .font(.custom("Comfortaa", size: 20))
                                            .foregroundColor(.vBlue)
                                        if processingSubscribe {
                                            ProgressView()
                                        }
                                    }
                                    .padding()
                                }
                                .disabled(processingSubscribe)
                                .buttonStyle(NeumorphicButtonStyle(shape: RoundedRectangle(cornerRadius: 25)))
                                .alert("Could not load purchase, check your connection.", isPresented: $presentingSubscribeError) {
                                    Button("Ok") { }
                                }
                                
                                HStack(spacing: 12) {
                                    Button {
                                        Task {
                                            processingRestore = true
                                            do {
                                                try await subscriptionService.restorePurchases()
                                                dismiss()
                                            } catch {
                                                print(error.localizedDescription)
                                                processingRestore = false
                                                presentingRestoreError = true
                                            }
                                        }
                                    } label: {
                                        Text("Restore purchases")
                                            .font(.caption)
                                            .foregroundColor(.text)
                                    }
                                    .alert("Could not restore purchases, check your connection.", isPresented: $presentingSubscribeError) {
                                        Button("Ok") { }
                                    }
                                    
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(.text)
                                    
                                    Link("Terms & privacy", destination: URL(string: "https://hiberniavpn.com#legal")!) // Present legal information before subscribe action
                                        .font(.caption)
                                        .foregroundColor(.text)
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    SubscribeModalView()
}
