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
    #if targetEnvironment(macCatalyst)
        let providerFactory = DeviceCHeckAppCheckProviderFactory()
    #else
        let providerFactory = AppAttestAppCheckProviderFactory()
    #endif
        
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
        
        vpnService = VPNService()
        subscriptionService = IAPSubscriptionService()
    }

    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(vpnService).environmentObject(subscriptionService)
        }
    }
}
