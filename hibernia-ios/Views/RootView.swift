//
//  RootView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var rcService: RemoteConfigService

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            SlideOverContainerView()
        }
        .task {
            do {
                try await rcService.fetchAndActivate()
            } catch {
                print("Could not load remote configuration")
            }
        }
    }
}
