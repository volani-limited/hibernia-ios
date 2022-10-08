//
//  IAPService2.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 04/10/2022.
//

import Foundation
import StoreKit

typealias ProductIdentifier = String

public enum StoreError: Error {
    case failedVerification
}

class IAPSubscriptionService: ObservableObject {
    static let subscriptionProductId = "hp1m"
    
    @Published var subscribed: Bool = false
    @Published var processing: Bool = false
    @Published var iapSubscriptionServiceError: Error?
    @Published var retryHandler: (@MainActor () async -> ())?

    var originalTransactionID: UInt64?

    var subscriptionProduct: Product?
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        updateListenerTask = listenForTransactions()

        Task {
            await setSubscriptionProduct()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    @MainActor func setSubscriptionProduct() async {
        do {
            self.subscriptionProduct = try await getProduct(productIdentifier: IAPSubscriptionService.subscriptionProductId)
        } catch {
            self.iapSubscriptionServiceError = error
            self.subscriptionProduct = nil

            self.retryHandler = setSubscriptionProduct
        }
    }
    
    @MainActor
    func getProduct(productIdentifier: ProductIdentifier) async throws -> Product? {
        let products = try await Product.products(for: Array(arrayLiteral: productIdentifier))
        return products[0]
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        let result = await Transaction.currentEntitlement(for: IAPSubscriptionService.subscriptionProductId)
        
        do {
            if let result {
                let transaction = try checkVerified(result)
                print("Successfully verified subscription")
                originalTransactionID = transaction.originalID
                subscribed = true
            } else {
                print("User not subscribed")
                subscribed = false
            }
        } catch {
            print("Could not verify subscription")
            self.iapSubscriptionServiceError = error
            
            retryHandler = updateSubscriptionStatus
        
            subscribed = false
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

                await updateSubscriptionStatus()
                
                await transaction.finish()
            default:
                return
            }
        } catch {
            self.iapSubscriptionServiceError = error
            retryHandler = subscribe
        }
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
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T{
        switch result {
            case .unverified:
                throw StoreError.failedVerification
            case .verified(let transaction):
                return transaction
        }
    }
}
