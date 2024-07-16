//
//  RedeemCodeModalView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 09/07/2024.
//

import SwiftUI

struct RedeemLicenseKeyModalView: View {
    @EnvironmentObject var subscriptionService: RevenueCatSubscriptionService
    
    @Environment(\.dismiss) var dismiss
    
    var parentDismissAction: DismissAction
    
    @State var enteredLicenseKey: String = ""
    @State private var processingLicenseKey: Bool = false
    
    @State private var presentingLicenseKeyRedeemError: Bool = false
    @State private var licenseKeyRedeemErrorMessage: String?
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 15) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.text)
                            .padding()
                    }
                    .buttonStyle(NeumorphicButtonStyle(shape: Circle()))
                    Spacer()
                }
                
                VStack {
                    TextField("License key..", text: $enteredLicenseKey)
                        .padding()
                        .background(NeumorphicShape(isHighlighted: true, shape: RoundedRectangle(cornerRadius: 25)))
                    Text("Redeeming a license key will not cancel any existing subscriptions.")
                        .font(.caption)
                        .foregroundColor(.text)
                }
                
                ZStack {
                    Button {
                        processingLicenseKey = true
                        Task {
                            do {
                                try await subscriptionService.redeemLicenseKey(enteredLicenseKey)
                                dismiss()
                                parentDismissAction()
                            } catch RevenueCatSubscriptionService.LicenseKeyRedeemError.invalidLicenseKeyError {
                                presentingLicenseKeyRedeemError = true
                                licenseKeyRedeemErrorMessage = "Invalid license key, try again."
                            } catch {
                                presentingLicenseKeyRedeemError = true
                                licenseKeyRedeemErrorMessage = "Could not redeem key, check your connection."
                            }
                            enteredLicenseKey = ""
                            processingLicenseKey = false
                        }
                    } label: {
                        Text("Redeem")
                            .bold()
                            .font(.custom("Comfortaa", size: 20))
                            .foregroundColor(.vBlue)
                            .padding()
                    }
                    .disabled(enteredLicenseKey.isEmpty)
                    .buttonStyle(NeumorphicButtonStyle(shape: RoundedRectangle(cornerRadius: 25)))
                    .alert(licenseKeyRedeemErrorMessage ?? "Error", isPresented: $presentingLicenseKeyRedeemError) {
                        Button("Ok") { }
                    }
                    .opacity(processingLicenseKey ? 0 : 1)
                    
                    ProgressView()
                        .font(.system(size: 20))
                        .padding()
                        .background(NeumorphicShape(shape: Circle()))
                        .opacity(processingLicenseKey ? 1 : 0)
                }
                Spacer()
            }
            .padding()
        }
        .presentationDetents([.fraction(0.3)])
    }
}
