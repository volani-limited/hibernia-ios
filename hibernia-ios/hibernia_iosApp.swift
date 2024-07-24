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
    private var settingsService: UserSettingsService

    init() {
        if ProcessInfo.processInfo.isiOSAppOnMac { // Configure Firebase AppCheck
            let providerFactory = DeviceCheckAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        } else {
            let providerFactory = AppAttestAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        }
        
        FirebaseApp.configure()
        
        rcService = RemoteConfigService()
        vpnService = VPNService(destinations: rcService.remoteConfiguration.destinations) // Instantiate local services
        subscriptionService = RevenueCatSubscriptionService()
        settingsService = UserSettingsService()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vpnService)
                .environmentObject(subscriptionService)
                .environmentObject(rcService)
                .environmentObject(settingsService)
                .task {
                    await vpnService.prepare()
                }
        }
    }
}
