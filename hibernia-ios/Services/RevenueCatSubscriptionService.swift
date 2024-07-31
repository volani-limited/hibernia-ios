//
//  RevenueCatService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 28/06/2024.
//

import Foundation
import RevenueCat
import StoreKit

import FirebaseAppCheck

@MainActor
class RevenueCatSubscriptionService: ObservableObject {
    static let apiKey: String = "appl_dFHGAJLCuWiOtNQROyLQFnqYLZF"
    static let premiumEntitlementId = "hibernia-premium"
    
    @Published private(set) var subscriptionStatus: SubscriptionStatusType
    @Published private(set) var subscriptionExpiryDate: Date?
    
    private(set) var customerInfo: CustomerInfo?
    private(set) var appUserId: String
    
    init() {
        Purchases.configure(withAPIKey: RevenueCatSubscriptionService.apiKey)
        
        let defaults = UserDefaults.standard
        subscriptionStatus = SubscriptionStatusType(rawValue: defaults.string(forKey: "cachedSubscriptionStatus") ?? "notSubscribed") ?? .notSubscribed

        self.appUserId = Purchases.shared.appUserID
        
        Task {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask { await self.beginRecievingCustomerInfoStream() }
                taskGroup.addTask { await self.syncStoreKitWithRevenueCat() }
            }
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
        let entitlement = customerInfo?.entitlements[RevenueCatSubscriptionService.premiumEntitlementId]
        
        guard let entitlement = entitlement, entitlement.isActive else {
            self.subscriptionStatus = .notSubscribed
            self.subscriptionExpiryDate = nil
            return
        }
        
        
        if entitlement.productIdentifier.hasPrefix("rc_promo") {
            self.subscriptionStatus = .licenseKey
        } else if entitlement.expirationDate == nil {
            self.subscriptionStatus = .lifetime
        } else if entitlement.ownershipType == .familyShared {
            self.subscriptionStatus = .familyShared
        } else if entitlement.productIdentifier.contains("f") { // Could retrieve product with ID and then check if product is family shareable but this adds complexity
            self.subscriptionStatus = .familyShareable
        } else {
            self.subscriptionStatus = .standardSubscription
        }
        
        self.subscriptionExpiryDate = entitlement.expirationDate
        
        let defaults = UserDefaults.standard
        defaults.set(self.subscriptionStatus.rawValue, forKey: "cachedSubscriptionStatus")
    }
    
    func forceRefreshCustomerInfo() async throws {
        self.customerInfo = try await Purchases.shared.customerInfo()
        updatedPublishedEntitlementStatus()
    }
    
    func getOfferings() async throws -> Offerings {
        return try await Purchases.shared.offerings()
    }
    
    func restorePurchases() async throws {
        let _ = try await Purchases.shared.restorePurchases()
    }
    
    func purchase(package: Package) async throws {
        let result = try await Purchases.shared.purchase(package: package)
        guard result.userCancelled == false else {
            throw SubscriptionServiceError.userCancelled
        }
    }
    
    static func getPaywallInformation(for offering: Offering) -> PaywallInformation {
        let headlineDict = offering.getMetadataValue(for: "headline", default: [:])
        
        let headline = headlineDict["text"] as! String
        let headlineAppendsLocalizedPrice = headlineDict["appendsLocalizedPrice"] as! Bool
        
        let subhead = offering.getMetadataValue(for: "subhead", default: "")
        
        let bullets = offering.getMetadataValue(for: "bullets", default: [String]())
        
        return PaywallInformation(headline: headline, headlineAppendsLocalizedPrice: headlineAppendsLocalizedPrice, subhead: subhead, bullets: bullets)
    }

    private func yearsBetweenDate(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: startDate, to: endDate)

        return components.year!
    }
    
    enum SubscriptionServiceError: Error {
        case userCancelled
    }
    
    enum LicenseKeyRedeemError: Error {
        case couldNotRetrieveCustomerInfo
        case couldNotRedeemLicenseKey
        case invalidLicenseKeyError
    }
    
    enum SubscriptionStatusType: String {
        case notSubscribed
        case standardSubscription
        case familyShareable
        case familyShared
        case lifetime
        case licenseKey
        
        var statusDisplay: String {
            switch self {
            case .notSubscribed:
                return "Not subscribed"
            case .standardSubscription:
                return "Subscribed"
            case .familyShareable:
                return "Subscribed to family"
            case .familyShared:
                return "Subscribed via family"
            case .lifetime:
                return "Lifetime"
            case .licenseKey:
                return "Activated"
            }
        }
    }
    
    struct PaywallInformation {
        var headline: String
        var headlineAppendsLocalizedPrice: Bool
        var subhead: String
        var bullets: [String]
    }
}

extension RevenueCatSubscriptionService {
    private func syncStoreKitWithRevenueCat() async {
        func checkVerified<T>(_ result: StoreKit.VerificationResult<T>) throws -> T {
            switch result {
                case .unverified:
                    throw StoreError.failedVerification
                case .verified(let transaction):
                    return transaction
            }
        }
        
        do {
            let result = await Transaction.currentEntitlement(for: "hp1m")
            
            if let result {
                let transaction = try checkVerified(result)
                print("Successfully verified transaction: \(transaction.id) from StoreKit")
                
                let customerInfo = try await Purchases.shared.customerInfo()
                
                if customerInfo.entitlements.active.isEmpty {
                    let _ = try await Purchases.shared.syncPurchases()
                    try await forceRefreshCustomerInfo()
                }
            }
        } catch {
            print("Could not sync StoreKit with RevenueCat: \(error.localizedDescription)")
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}

extension RevenueCatSubscriptionService {
    func redeemLicenseKey(_ key: String) async throws {
        let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false)
        
        let url = URL(string: "https://europe-west2-hiberniavpn.cloudfunctions.net/v2-redeem-license?key=" + key) // Create request url
        var request = URLRequest(url: url!)
        
        guard let customerInfo = customerInfo else {
            throw LicenseKeyRedeemError.couldNotRetrieveCustomerInfo
        }
        
        request.setValue(appCheckToken.token, forHTTPHeaderField: "App-Check-Token")
        request.setValue(customerInfo.id, forHTTPHeaderField: "App-User-Id")
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpsResponse = response as? HTTPURLResponse else { // Make request and handle error
            throw LicenseKeyRedeemError.couldNotRedeemLicenseKey
        }
        
        if httpsResponse.statusCode == 402 {
            throw LicenseKeyRedeemError.invalidLicenseKeyError
        } else if httpsResponse.statusCode != 200 {
            throw LicenseKeyRedeemError.couldNotRetrieveCustomerInfo
        }
        
        try await forceRefreshCustomerInfo()
    }
}
