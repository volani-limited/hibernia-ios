//
//  hibernia_iosApp.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/09/2022.
//

import SwiftUI
import Firebase
import SwiftyBeaver

private let log = SwiftyBeaver.self

@main
struct hibernia_iosApp: App {
    var authService: AuthService
    var vpnService: VPNService
    var subscriptionService: IAPSubscriptionService
    
    init() {
        FirebaseApp.configure()
        authService = AuthService()
        vpnService = VPNService()
        subscriptionService = IAPSubscriptionService()
        let logDestination = ConsoleDestination()
        logDestination.minLevel = .debug
        logDestination.format = "$DHH:mm:ss$d $L $N.$F:$l - $M"
        log.addDestination(logDestination)
    }

    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(authService).environmentObject(vpnService).environmentObject(subscriptionService)
        }
    }
}
