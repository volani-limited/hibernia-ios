//
//  PaywallInformationView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 16/07/2024.
//

import SwiftUI
import RevenueCat

struct PaywallInformationView: View {
    @Environment(\.colorScheme) var colorScheme

    var paywallInformation: RevenueCatSubscriptionService.PaywallInformation
    var offering: Offering
    
    var body: some View {
                VStack {
                    Image(colorScheme == .light ? "logo" : "logoDark")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 275)
                    
                    VStack(spacing: 15) {
                        if paywallInformation.headlineAppendsLocalizedPrice {
                            Text(.init(paywallInformation.headline + offering.availablePackages.first!.localizedPriceString + " " + (offering.availablePackages.first!.packageType.displayedDuration ?? "")))
                                .fontWeight(.bold)
                                .font(.custom("Comfortaa", size: 25, relativeTo: .largeTitle))
                                .foregroundColor(.turquoise)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                        } else {
                            Text(.init(paywallInformation.headline))
                                .fontWeight(.bold)
                                .font(.custom("Comfortaa", size: 25, relativeTo: .largeTitle))
                                .foregroundColor(.turquoise)
                        }
                        
                        Text(.init(paywallInformation.subhead))
                            .fontWeight(.bold)
                            .font(.custom("Comfortaa", size: 20, relativeTo: .largeTitle))
                            .foregroundColor(.text)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(paywallInformation.bullets, id: \.self) { bullet in
                                HStack {
                                    Text("•")
                                    Text(.init(bullet))
                                }
                                .font(.custom("Comfortaa", size: 15, relativeTo: .title2))
                                .foregroundColor(.titleText)
                                .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(.horizontal)
    }
}

extension RevenueCat.PackageType { // TODO: Localize this.
    var displayedDuration: String? {
        switch self {
        case .unknown:
            return nil
        case .custom:
            return nil
        case .lifetime:
            return "for life"
        case .annual:
            return "per year"
        case .sixMonth:
            return"every six months"
        case .threeMonth:
            return"every three months"
        case .twoMonth:
            return "every two months"
        case .monthly:
            return "per month"
        case .weekly:
            return "per week"
        }
    }
}
