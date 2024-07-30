//
//  RootView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var vpnService: VPNService
    @EnvironmentObject var settingsService: UserSettingsService
    @EnvironmentObject var rcService: RemoteConfigService

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            SlideOverContainerView()
        }
        .preferredColorScheme(settingsService.preferredAppAppearance.colorSchemeEquivalent)
        .dynamicTypeSize(.large) // Fix/override dyanmic type size, this will be addressed in a future update.
        .task {
            await vpnService.prepare()

            do {
                try await rcService.fetchAndActivate()
            } catch {
                print("Could not load remote configuration")
            }
        }
    }
}
