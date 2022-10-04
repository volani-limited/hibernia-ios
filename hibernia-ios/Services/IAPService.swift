//
//  IAPService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 04/10/2022.
//

/*
import Foundation
import StoreKit

typealias ProductIdentifier = String

class IAPService: NSObject, ObservableObject {
    @Published var subscribed: Bool
    @Published var transactionError: Error?
    
    var productIdentifiers: Set<ProductIdentifier> = ["uk.co.volani.hibernia-ios.hp1m"]
    var purchasedProductIdentifiers: Set<ProductIdentifier>
    var productsRequest: SKProductsRequest?
    
    override init() {
        purchasedProductIdentifiers = Set<ProductIdentifier>()
        
        for productIdentifier in productIdentifiers {
            if UserDefaults.standard.bool(forKey: productIdentifier) {
                print("Previously purchased: " + productIdentifier)
                purchasedProductIdentifiers.insert(productIdentifier)
            }
        }
        
        if purchasedProductIdentifiers.contains("uk.co.hibernia-ios.hp1m") {
            subscribed = true
        } else {
            subscribed = false
        }
        
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
    
    func buy(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func requestProducts() {
        productsRequest?.cancel()
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
}

extension IAPService: SKProductsRequestDelegate {
    
}

extension IAPService: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                if let transactionError = transaction.error {
                    self.transactionError = transactionError
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
*/
