//
//  SlideOverContainerView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

// Would like to use ViewBuilder to create generic slideovercontainer but need to find a workaround as child views need to have access to inLeftHandPosition to dismiss themselves/return to other view

import SwiftUI

struct SlideOverContainerView: View {
    @State private var inLeftHandPosition: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabBarContainerView(presentingLocationSelectorView: $inLeftHandPosition)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                DestinationSelectorView(presenting: $inLeftHandPosition)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: geometry.size.width)
            }
            .offset(x: inLeftHandPosition ? -geometry.size.width : 0)
        }
    }
}
