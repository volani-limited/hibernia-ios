//
//  hibernia_iosApp.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/09/2022.
//

import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct hibernia_iosApp: App {
    private var vpnService: VPNService
    private var subscriptionService: RevenueCatSubscriptionService
    
    init() {
        if ProcessInfo.processInfo.isiOSAppOnMac { // Configure Firebase AppCheck
            let providerFactory = DeviceCheckAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        } else {
            let providerFactory = AppAttestAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        }
        
        FirebaseApp.configure()
        
        vpnService = VPNService() // Instantiate local services
        subscriptionService = RevenueCatSubscriptionService()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vpnService)
                .environmentObject(subscriptionService)
                .task {
                    await vpnService.prepare()
                }
        }
    }
}
