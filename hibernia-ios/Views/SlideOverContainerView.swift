//
//  SlideOverContainerView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct SlideOverContainerView: View {
    @EnvironmentObject var vpnService: VPNService
    
    @State private var inLeftHandPosition: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabBarContainerView(presentingDestinationSelectorView: $inLeftHandPosition)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                DestinationSelectorView(presenting: $inLeftHandPosition)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: geometry.size.width)
            }
            .offset(x: inLeftHandPosition ? -geometry.size.width : 0)
        }
    }
}
