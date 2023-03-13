//
//  hibernia_iosApp.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/09/2022.
//

import SwiftUI
import Firebase
import FirebaseAppCheck
import Qonversion
import RevenueCat

@main
struct hibernia_iosApp: App {
    var vpnService: VPNService
    var subscriptionService: IAPSubscriptionService
    
    init() {
        if ProcessInfo.processInfo.isiOSAppOnMac {
            let providerFactory = DeviceCheckAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        } else {
            let providerFactory = AppAttestAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        }
        
        FirebaseApp.configure()
        
        vpnService = VPNService()
        subscriptionService = IAPSubscriptionService()
        
        let config = Qonversion.Configuration(projectKey: "_VyGtgouQv_ECvbgQyoG0lseCF24vnp-", launchMode: .analytics)
        Qonversion.initWithConfig(config)
        
        Purchases.configure(
          with: Configuration.Builder(withAPIKey: "appl_dFHGAJLCuWiOtNQROyLQFnqYLZF")
            .with(observerMode: true)
            .build()
        )
        
    }

    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(vpnService).environmentObject(subscriptionService)
        }
    }
}
