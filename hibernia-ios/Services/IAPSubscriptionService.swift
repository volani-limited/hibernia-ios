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
    @Published var error: Error?
    
    var originalTransactionID: UInt64?

    var subscriptionProduct: Product?
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        updateListenerTask = listenForTransactions()

        Task {
            subscriptionProduct = await getSubscriptionProduct()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }

    
    @MainActor
    func getSubscriptionProduct() async -> Product? {
        do {
            let products = try await Product.products(for: Array(arrayLiteral: IAPSubscriptionService.subscriptionProductId))
            return products[0]
        } catch {
            self.error = error
            return nil
        }
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
            self.error = error
            subscribed = false
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    await self.updateSubscriptionStatus()
                    self.processing = false
                    await transaction.finish()
                }
            }
        }
    }
    
    @MainActor
    func subscribe() async {
        processing = true
        do {
            let result = try await subscriptionProduct!.purchase()
            
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                
                processing = false
                await updateSubscriptionStatus()
                
                await transaction.finish()
            default:
                processing = false
                return
            }
        } catch {
            self.error = error
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
