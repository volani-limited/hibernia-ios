//
//  hibernia_iosApp.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/09/2022.
//

import SwiftUI
import Firebase

@main
struct hibernia_iosApp: App {
    var authService: AuthService
    var vpnService: VPNService
    
    init() {
        FirebaseApp.configure()
        authService = AuthService()
        vpnService = VPNService()
    }

    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(authService).environmentObject(vpnService)
        }
    }
}
