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
    var vpnService: VPNService
    var subscriptionService: IAPSubscriptionService
    
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
        subscriptionService = IAPSubscriptionService()
    }

    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(vpnService).environmentObject(subscriptionService)
        }
    }
}
