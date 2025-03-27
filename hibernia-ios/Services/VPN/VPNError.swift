//
//  VPNError.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 27/03/2025.
//

import Foundation

enum VPNError: LocalizedError {
    case configurationRequestError
    case subscriptionPaymentError
    
    public var errorDescription: String? { // Define VPN specific errors
        switch self {
        case .configurationRequestError:
            return "Configuration request failed."
        case .subscriptionPaymentError:
            return "Subscription could not be verified."
        }
    }
}
