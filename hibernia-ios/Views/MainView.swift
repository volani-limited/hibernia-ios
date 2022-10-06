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
                    Text("Hibernia VPN")
                        .font(.custom("Comfortaa", size: 30))
                        .foregroundStyle(LinearGradient(.highlightStart, .highlightEnd))
                    
                    Spacer().frame(height: geometry.size.width/4)
                    if !subscriptionService.subscribed {
                        PurchaseSubscriptionButtonView()
                    }
                    
                    VPNConnectButton()//.disabled(!subscriptionService.subscribed)
                }.frame(width: geometry.size.width, height:geometry.size.height)

                CountrySelectorView()
                    .frame(width: geometry.size.width, height:geometry.size.height)
                    .offset(x: geometry.size.width)
                
                ViewSwitcherBarButtonView(isOpen: $isOpen, geometry: geometry)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 80)
            }
            .background(
                LinearGradient(Color.backgroundStart, Color.backgroundEnd)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geometry.size.width*2, height: geometry.size.height)
                    .offset(x: geometry.size.width/2))
            .offset(x: isOpen ? -geometry.size.width + dragAmount : dragAmount)
            /*.gesture(DragGesture().onChanged { value in
                if value.translation.width.sign == .minus || isOpen {
                    dragAmount = value.translation.width
                }
            }.onEnded { value in
                dragAmount = 0
                if abs(value.translation.width) > (geometry.size.width - 50) / 2 {
                    if value.translation.width.sign == .plus {
                        withAnimation {
                            isOpen = false
                        }
                        
                    } else {
                        withAnimation {
                            isOpen = true
                        }
                    }
                }
               
            })*/
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()//.scaleEffect(0.5)
    }
}
