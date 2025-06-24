//
//  SubscriptionOptionsSubscribeView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/07/2024.
//

import SwiftUI
import RevenueCat

struct PaywallPackgeOptionsSubscribeView: View {
    @EnvironmentObject var subscriptionService: RevenueCatSubscriptionService
    var packages: [Package]
    @Environment(\.dismiss) var dismiss
    
    @State var selectedPackage: Package
    
    @Binding var processingSubscribe: Bool
    @State private var presentingSubscribeError: Bool = false
    
    var body: some View {
        VStack (spacing: 20) {
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
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding()
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(NeumorphicButtonStyle(shape: RoundedRectangle(cornerRadius: 15), isHighlighted: selectedPackage.identifier == package.identifier))
                    .disabled(processingSubscribe)
                }
            }
            
            VStack {
                ZStack {
                    Button {
                        processingSubscribe = true
                        Task {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            
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
                            if subscriptionService.customerInfo?.activeSubscriptions.contains(selectedPackage.storeProduct.productIdentifier) ?? false || subscriptionService.customerInfo?.nonSubscriptions.map({ return $0.productIdentifier }).contains(selectedPackage.storeProduct.productIdentifier) ?? false {
                                Text("Purchased")
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
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
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
                    .disabled(processingSubscribe || subscriptionService.customerInfo?.activeSubscriptions.contains(selectedPackage.storeProduct.productIdentifier) ?? false || subscriptionService.customerInfo?.nonSubscriptions.map({ return $0.productIdentifier }).contains(selectedPackage.storeProduct.productIdentifier) ?? false)
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
                
                //Spacer()
                   // .frame(height: 10)
                
                Text("Purchasing a lifetime subscription will not automatically cancel any existing subscriptions. Do this manually in Settings.").fixedSize(horizontal: false, vertical: true)
                    .font(.caption)
                    .foregroundStyle(Color.text)
                    .padding(.horizontal)
                    .opacity(selectedPackage.packageType == .lifetime && !(subscriptionService.subscriptionStatus != .notSubscribed || subscriptionService.subscriptionStatus != .lifetime) ? 1 : 0)
            }
        }
        .padding()
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
