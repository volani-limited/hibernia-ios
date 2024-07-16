//
//  SubscriptionOptionsSubscribeView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/07/2024.
//

import SwiftUI
import RevenueCat

struct SubscriptionOptionsSubscribeView: View {
    @EnvironmentObject var subscriptionService: RevenueCatSubscriptionService
    var packages: [Package]
    
    @Environment(\.dismiss) var dismiss
    
    @State var selectedPackage: Package
    
    @State private var processingSubscribe: Bool = false
    @State private var presentingSubscribeError: Bool = false
    
    @State private var processingRestore: Bool = false
    @State private var presentingRestoreError: Bool = false
    @State private var presentingRestoreSuccess: Bool = false
    
    @State private var presentingRedeemLicenseKeyModal: Bool = false
    
    var body: some View {
        VStack {
            VStack(spacing: 12) {
                ForEach(packages, id: \.identifier) { package in
                    Button {
                        self.selectedPackage = package
                    } label: {
                        HStack {
                            Spacer()
                            Text(package.storeProduct.localizedTitle + " for " + package.localizedPriceString)
                                .bold()
                                .font(.custom("Comfortaa", size: 18))
                                .foregroundStyle(Color.text)
                                .padding()
                            Spacer()
                        }
                    }
                    .buttonStyle(NeumorphicButtonStyle(shape: RoundedRectangle(cornerRadius: 15), isHighlighted: selectedPackage.identifier == package.identifier))
                    .disabled(processingSubscribe)
                }
            }
            
            
            VStack(spacing: 20) {
                Spacer().frame(height: 10)
                
                VStack {
                    ZStack {
                        Button {
                            processingSubscribe = true
                            Task {
                                do {
                                    try await subscriptionService.purchase(package: selectedPackage)
                                    dismiss()
                                } catch RevenueCatSubscriptionService.SubscriptionServiceError.userCancelled {
                                    
                                } catch {
                                    print(error.localizedDescription)
                                    presentingSubscribeError = true
                                }
                                processingSubscribe = false
                            }
                        } label: {
                            HStack {
                                Spacer()
                                if subscriptionService.customerInfo?.activeSubscriptions.contains(selectedPackage.identifier) ?? false || subscriptionService.customerInfo?.nonSubscriptions.map({ return $0.productIdentifier }).contains(selectedPackage.storeProduct.productIdentifier) ?? false {
                                    Text("Already Purchased")
                                        .bold()
                                        .font(.custom("Comfortaa", size: 20))
                                        .foregroundColor(.text)
                                } else if selectedPackage.packageType == .lifetime {
                                    Text("Purchase")
                                        .bold()
                                        .font(.custom("Comfortaa", size: 20))
                                        .foregroundColor(.vBlue)
                                } else {
                                    if let introductoryDiscount = selectedPackage.storeProduct.introductoryDiscount {
                                        Text("Subscribe with a \(introductoryDiscount.subscriptionPeriod.displayed()) free trial")
                                            .bold()
                                            .font(.custom("Comfortaa", size: 20))
                                            .foregroundColor(.vBlue)
                                    } else {
                                        Text("Subscribe")
                                            .bold()
                                            .font(.custom("Comfortaa", size: 20))
                                            .foregroundColor(.vBlue)
                                    }
                                    
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        .disabled(processingSubscribe || processingRestore || subscriptionService.customerInfo?.activeSubscriptions.contains(selectedPackage.identifier) ?? false || subscriptionService.customerInfo?.nonSubscriptions.map({ return $0.productIdentifier }).contains(selectedPackage.storeProduct.productIdentifier) ?? false)
                        .buttonStyle(NeumorphicButtonStyle(shape: RoundedRectangle(cornerRadius: 25)))
                        .alert("Could not purchase, check your connection.", isPresented: $presentingSubscribeError) {
                            Button("Ok") { }
                        }
                        .opacity(processingSubscribe ? 0 : 1)
                        
                        ProgressView()
                            .font(.system(size: 20))
                            .padding()
                            .background(NeumorphicShape(shape: Circle()))
                            .opacity(processingSubscribe ? 1 : 0)
                    }
                    
                    Text("Purchasing a lifetime subscription will not automatically cancel\nany existing subscriptions. Do this manually in Settings.") //TODO: fix overrunning text
                        .font(.caption)
                        .foregroundStyle(Color.text)
                        .padding()
                        .opacity(selectedPackage.packageType == .lifetime ? 1 : 0)
                    
                    if let settingsUrl = subscriptionService.customerInfo?.managementURL {
                        if subscriptionService.subscriptionStatus != .notSubscribed {
                            Button {
                                UIApplication.shared.open(settingsUrl)
                            } label: {
                                Text("Manage in settings")
                                    .font(.caption)
                                    .foregroundStyle(Color.text)
                                    .padding()
                            }
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    Button {
                        Task {
                            processingRestore = true
                            do {
                                try await subscriptionService.restorePurchases()
                                presentingRestoreSuccess = true
                            } catch {
                                print(error.localizedDescription)
                                processingRestore = false
                                presentingRestoreError = true
                            }
                        }
                    } label: {
                        ZStack {
                            Text("Restore purchases")
                                .font(.caption)
                                .foregroundColor(.text)
                            
                            ProgressView()
                                .opacity(processingRestore ? 1 : 0)
                            
                        }
                    }
                    .disabled(processingRestore)
                    .alert("Could not restore purchases, check your connection.", isPresented: $presentingSubscribeError) {
                        Button("Ok") { }
                    }
                    .alert("Purchases restored successfully.", isPresented: $presentingRestoreSuccess) {
                        Button("Ok") { dismiss() }
                    }
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.text)
                    
                    Link("Terms & privacy", destination: URL(string: "https://hiberniavpn.com#legal")!) // Present legal information before subscribe action
                        .font(.caption)
                        .foregroundColor(.text)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.text)
                    
                    Button {
                        presentingRedeemLicenseKeyModal = true
                    } label: {
                        Text("Redeem license key")
                            .font(.caption)
                            .foregroundColor(.text)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $presentingRedeemLicenseKeyModal) {
            RedeemLicenseKeyModalView(parentDismissAction: dismiss)
        }
    }
}

extension SubscriptionPeriod {
    var displayedDuration: String {
        switch self.unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        }
    }
    
    func displayed() -> String {
        return "\(self.value)-\(self.displayedDuration)"
    }
}
