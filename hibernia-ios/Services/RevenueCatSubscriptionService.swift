//
//  RevenueCatService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 28/06/2024.
//

import Foundation
import RevenueCat
import StoreKit

@MainActor
class RevenueCatSubscriptionService: ObservableObject {
    @Published private(set) var entitledToPremium: Bool
    
    private(set) var customerInfo: CustomerInfo?
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_dFHGAJLCuWiOtNQROyLQFnqYLZF")
        
        entitledToPremium = false
        
        Task {
            try? await syncStoreKitWithRevenueCat()
            await beginRecievingCustomerInfoStream()
        }
    }
    
    private func beginRecievingCustomerInfoStream() async {
        do {
            for try await customerInfo in Purchases.shared.customerInfoStream {
                self.customerInfo = customerInfo
                updatedPublishedEntitlementStatus()
            }
        } catch {
            fatalError("Could not begin recieving values from Purchases.shared.customerInfoStream")
        }
    }
    
    private func updatedPublishedEntitlementStatus() {
        if self.customerInfo?.entitlements["hibernia-premium"]?.isActive == true {
            self.entitledToPremium = true
        }
    }
    
    func forceRefreshCustomerInfo() async throws {
        self.customerInfo = try await Purchases.shared.customerInfo()
        updatedPublishedEntitlementStatus()
    }
    
    func getOfferings() async throws -> Offerings {
        try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.getOfferings { (offerings, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: offerings!) // TODO: propagate error if offerings is nil?
            }
        }
    }
    
    func restorePurchases() async throws {
        let _ = try await Purchases.shared.restorePurchases()
    }
    
    func purchase(package: Package) async throws {
        let _ = try await Purchases.shared.purchase(package: package)
    }
    
    enum IAPSubscriptionServiceError: Error {
        case couldNotPurchase
        case couldNotRetrieveProducts
    }
}

extension RevenueCatSubscriptionService {
    private func syncStoreKitWithRevenueCat() async throws {
        func checkVerified<T>(_ result: StoreKit.VerificationResult<T>) throws -> T {
            switch result {
                case .unverified:
                    throw StoreError.failedVerification
                case .verified(let transaction):
                    return transaction
            }
        }
        
        let products = try await Product.products(for: Array(arrayLiteral: "hp1m"))
        
        if products.isEmpty {
            throw IAPSubscriptionServiceError.couldNotRetrieveProducts
        }
        
        let product = products[0]
        
        let result = await Transaction.currentEntitlement(for: "hp1m")
        
        if let result {
            let transaction = try checkVerified(result)
            print("Successfully verified subscription from StoreKit")
            
            let customerInfo = try await Purchases.shared.customerInfo()
            
            if customerInfo.entitlements.active.isEmpty {
                let _ = try await Purchases.shared.syncPurchases()
            }
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
