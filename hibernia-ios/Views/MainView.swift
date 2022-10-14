//
//  ContentView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/09/2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var subscriptionService: IAPSubscriptionService
    @EnvironmentObject var vpnService: VPNService

    @State private var isOpen = false
    
    @State var dragAmount = CGFloat(0)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Text("HiberniaVPN")
                        .font(.custom("Comfortaa", size: 30))
                        .foregroundStyle(LinearGradient(.highlightStart, .highlightEnd))
                    
                    Spacer().frame(height: geometry.size.width/4)
                    if subscriptionService.originalTransactionID == nil {
                        PurchaseSubscriptionButtonView()
                    }
                    ErrorDisplayView()
                    
                    VPNConnectButton().disabled(subscriptionService.originalTransactionID == nil)
                }.frame(width: geometry.size.width, height:geometry.size.height)

                CountrySelectorView()
                    .frame(width: geometry.size.width, height:geometry.size.height)
                    .offset(x: geometry.size.width)
                
                ViewSwitcherBarButtonView(isOpen: $isOpen, geometry: geometry)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 80)
                    .disabled(vpnService.status != .disconnected)
            }
            .background(
                LinearGradient(Color.backgroundStart, Color.backgroundEnd)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geometry.size.width*2, height: geometry.size.height)
                    .offset(x: geometry.size.width/2))
            .offset(x: isOpen ? -geometry.size.width + dragAmount : dragAmount)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
