//
//  TabBarContainerView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct TabBarContainerView: View {
    @State private var inLeftHandPosition: Bool = false
    @Binding var presentingLocationSelectorView: Bool

    var body: some View {
        GeometryReader { geometry in
            Group {
                if inLeftHandPosition {
                    SettingsView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    HomeView(presentingLocationSelectorView: $presentingLocationSelectorView)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .overlay(
                TabBarSelectorView(inLeftHandPosition: $inLeftHandPosition)
                    .frame(width: geometry.size.width / 5, height: 70)
                    .offset(y: geometry.size.height * 0.4) //TODO: use geometry reader correctly
            )
        }
    }
}
