//
//  RootView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct RootView: View {
    @State var presentingSubscriptionModal: Bool = false
    
    var body: some View {
        SlideOverContainerView()
            .background(Color.background.edgesIgnoringSafeArea(.all))
            .onAppear {
                Task {
                   // await vpnService.prepare() //TODO: Confirm correct placment of prepare()
                }
            }
    }
}
