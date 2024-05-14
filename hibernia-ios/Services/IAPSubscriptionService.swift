//
//  IAPService2.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 04/10/2022.
//

import Foundation
import StoreKit
import Combine
import RevenueCat

typealias ProductIdentifier = String

public enum StoreError: Error {
    case failedVerification
}

class IAPSubscriptionService: NSObject, ObservableObject {
    static let subscriptionProductID = "hp1m" // Define standard vpn IAP subscription product Id

    @Published var processing: Bool = false // Setup published varibles and error retry handler
    @Published var iapSubscriptionServiceError: Error?
    
    @Published var originalTransactionID: UInt64?
    @Published var subscriptionProduct: Product?
    
    private var updateListenerTask: Task<Void, Error>? = nil
    private var subscriptionStatusSubscription: AnyCancellable?
    
    override init() {
        let defaults = UserDefaults.standard
        originalTransactionID = UInt64(defaults.integer(forKey: "transactionID")) // Retrieve original subscriber/transaction ID if cached
        
        super.init()
        
        subscriptionStatusSubscription = $originalTransactionID.sink { value in
            defaults.set(value, forKey: "transactionID") // Cache original transaction ID when modified
        }
        
        updateListenerTask = listenForTransactions()
        
        SKPaymentQueue.default().add(self) // Add self to payment queue for app store originating transactions
        
        Task {
            await updateSubscriptionStatus() // Check subscription status
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
        subscriptionStatusSubscription?.cancel()
    }
    
    
    @MainActor
    func loadSubscriptionProduct() async throws {
        self.subscriptionProduct = try await getProduct(productIdentifier: IAPSubscriptionService.subscriptionProductID)
    }
    
    @MainActor
    func restorePurchases() async throws {
            try await AppStore.sync()
            await updateSubscriptionStatus()
    }
    
    @MainActor
    func getProduct(productIdentifier: ProductIdentifier) async throws -> Product? { // Retreive product
        let products = try await Product.products(for: Array(arrayLiteral: productIdentifier))
        
        if products.isEmpty {
            throw IAPSubscriptionServiceError.couldNotRetrieveProducts
        }
        
        return products[0]
    }
    
    @MainActor
    func updateSubscriptionStatus() async { // TODO: Check offline support
        processing = true
        let result = await Transaction.currentEntitlement(for: IAPSubscriptionService.subscriptionProductID) // Get and validate current entitlement
        
        do {
            if let result {
                let transaction = try checkVerified(result)
                print("Successfully verified subscription")
                originalTransactionID = transaction.originalID
            } else {
                print("User not subscribed")
                originalTransactionID = nil
            }
            self.iapSubscriptionServiceError = nil
        } catch {
            print("Could not verify subscription")
            originalTransactionID = nil
            
            self.iapSubscriptionServiceError = error
            
        }
        processing = false
    }
    
    @MainActor
    func subscribe() async throws {
        let result = try await subscriptionProduct?.purchase() // Purchase product and handle result
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            
            await transaction.finish()
            
            self.iapSubscriptionServiceError = nil
        case .userCancelled: // TODO: Confirm appropriate syntax
            return
        case .pending:
            return
        default:
            throw IAPSubscriptionServiceError.couldNotPurchase
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> { // Listen for transactions and process accordingly
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                }
            }
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T { // Verify receipt and return result
        switch result {
            case .unverified:
                throw StoreError.failedVerification
            case .verified(let transaction):
                return transaction
        }
    }
}

extension IAPSubscriptionService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // Implementation not needed due to Transaction.updates listener above.
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}

enum IAPSubscriptionServiceError: Error {
    case couldNotPurchase
    case couldNotRetrieveProducts
}
