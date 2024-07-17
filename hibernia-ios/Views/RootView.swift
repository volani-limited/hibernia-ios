//
//  RootView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            SlideOverContainerView()
        }
    }
}
