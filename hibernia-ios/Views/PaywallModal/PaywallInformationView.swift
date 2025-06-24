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
            GeometryReader { geometry in
                VStack {
                    Image(colorScheme == .light ? "logo" : "logoDark")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width / 3.5)
                    
                    VStack(spacing: 15) {
                        if paywallInformation.headlineAppendsLocalizedPrice {
                            Text(.init(paywallInformation.headline + offering.availablePackages.first!.localizedPriceString + " " + (offering.availablePackages.first!.packageType.displayedDuration ?? "")))
                                .fontWeight(.bold)
                                .font(.custom("Comfortaa", size: 25))
                                .foregroundColor(.turquoise)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                        } else {
                            Text(.init(paywallInformation.headline))
                                .fontWeight(.bold)
                                .font(.custom("Comfortaa", size: 25))
                                .foregroundColor(.turquoise)
                        }
                        
                        Text(.init(paywallInformation.subhead))
                            .fontWeight(.bold)
                            .font(.custom("Comfortaa", size: 20))
                            .foregroundColor(.text)
                        
                        VStack(alignment: .leading) {
                            ForEach(paywallInformation.bullets, id: \.self) { bullet in
                                Text(.init("• " + bullet))
                                    .font(.custom("Comfortaa", size: 15))
                                    .foregroundColor(.titleText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
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
