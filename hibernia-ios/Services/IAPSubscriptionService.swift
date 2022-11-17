//
//  IAPService2.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 04/10/2022.
//

import Foundation
import StoreKit
import Combine

typealias ProductIdentifier = String

public enum StoreError: Error {
    case failedVerification
}

class IAPSubscriptionService: NSObject, ObservableObject {
    static let subscriptionProductId = "hp1m"
    
    @Published var processing: Bool = false
    @Published var iapSubscriptionServiceError: Error?
    @Published var retryHandler: (@MainActor () async -> ())?

    @Published var originalTransactionID: UInt64?

    @Published var subscriptionProduct: Product?
    var updateListenerTask: Task<Void, Error>? = nil
    var subscriptionStatusUpdater: AnyCancellable?
    
    override init() {
        let defaults = UserDefaults.standard
        originalTransactionID = UInt64(defaults.integer(forKey: "transactionID"))
        
        super.init()
        
        subscriptionStatusUpdater = $originalTransactionID.sink { value in
            defaults.set(value, forKey: "transactionID")
        }
        
        updateListenerTask = listenForTransactions()
        
        SKPaymentQueue.default().add(self)
        
        Task {
            await setSubscriptionProduct()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
        subscriptionStatusUpdater?.cancel()
    }
    
    @MainActor
    func setSubscriptionProduct() async {
        do {
            self.subscriptionProduct = try await getProduct(productIdentifier: IAPSubscriptionService.subscriptionProductId)
            
            self.iapSubscriptionServiceError = nil
            self.retryHandler = nil
        } catch {
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
    func getProduct(productIdentifier: ProductIdentifier) async throws -> Product? {
        let products = try await Product.products(for: Array(arrayLiteral: productIdentifier))
        
        if products.isEmpty {
            throw IAPSubscriptionServiceError.couldNotRetrieveProducts
        }
        
        return products[0]
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        processing = true
        let result = await Transaction.currentEntitlement(for: IAPSubscriptionService.subscriptionProductId)
        
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
            processing = false
            
        }
        processing = false
    }
    
    @MainActor
    func subscribe() async {
        processing = true
        do {
            let result = try await subscriptionProduct?.purchase()
            
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
            processing = false
            self.iapSubscriptionServiceError = error
            retryHandler = subscribe
        }
        processing = false
    }
    
    func listenForTransactions() -> Task<Void, Error> {
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
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
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
