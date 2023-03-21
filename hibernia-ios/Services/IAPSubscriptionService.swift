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
    @Published var retryHandler: (@MainActor () async -> ())?

    @Published var originalTransactionID: UInt64?
    @Published var subscriptionProduct: Product?
    
    var updateListenerTask: Task<Void, Error>? = nil
    var subscriptionStatusSubscription: AnyCancellable?
    
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
            await setSubscriptionProduct()
            await updateSubscriptionStatus() // Check subscription status
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
        subscriptionStatusSubscription?.cancel()
    }
    
    @MainActor
    func setSubscriptionProduct() async { // Set product and handle error
        do {
            self.subscriptionProduct = try await getProduct(productIdentifier: IAPSubscriptionService.subscriptionProductID)
            
            self.iapSubscriptionServiceError = nil
            self.retryHandler = nil
        } catch {
            self.processing = false
            
            self.iapSubscriptionServiceError = error
            self.subscriptionProduct = nil

            self.retryHandler = setSubscriptionProduct
        }
    }
    
    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            self.iapSubscriptionServiceError = error
            self.retryHandler = nil
        }
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
    func updateSubscriptionStatus() async {
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
            self.retryHandler = nil
        } catch {
            print("Could not verify subscription")
            originalTransactionID = nil
            
            self.iapSubscriptionServiceError = error
            self.retryHandler = updateSubscriptionStatus
            
        }
        processing = false
    }
    
    @MainActor
    func subscribe() async {
        processing = true
        do {
            let result = try await subscriptionProduct?.purchase() // Purchase product and handle result
            
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                
                await transaction.finish()
                
                self.iapSubscriptionServiceError = nil
                self.retryHandler = nil
            case .userCancelled:
                processing = false
                
                self.iapSubscriptionServiceError = nil
                self.retryHandler = nil
            case .pending:
                processing = true
                
                self.iapSubscriptionServiceError = nil
                self.retryHandler = nil
            default:
                processing = false
                self.iapSubscriptionServiceError = IAPSubscriptionServiceError.couldNotPurchase
                self.retryHandler = { () -> Void in
                    self.iapSubscriptionServiceError = nil
                }
            }
        } catch {
            self.iapSubscriptionServiceError = error
            retryHandler = subscribe
        }
        processing = false
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
