//
//  hibernia_iosApp.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/09/2022.
//

import SwiftUI
import Firebase
import FirebaseRemoteConfig
import FirebaseAppCheck

@main
struct hibernia_iosApp: App {
    private var vpnService: VPNService
    private var subscriptionService: RevenueCatSubscriptionService
    private var rcService: RemoteConfigService

    init() {
        if ProcessInfo.processInfo.isiOSAppOnMac { // Configure Firebase AppCheck
            let providerFactory = DeviceCheckAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        } else {
            let providerFactory = AppAttestAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        }
        
        FirebaseApp.configure()

        let destinations = [VPNService.VPNDestination(id: "lon-1", displayedName: "London")]
        
        rcService = RemoteConfigService()
        vpnService = VPNService(destinations: rcService.remoteConfiguration.destinations) // Instantiate local services
        subscriptionService = RevenueCatSubscriptionService()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vpnService)
                .environmentObject(subscriptionService)
                .environmentObject(rcService)
                .task {
                    await vpnService.prepare()
                }
        }
    }
}
