//
//  ContentView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/09/2022.
//

import SwiftUI

struct MainView: View {
   // @EnvironmentObject var authService: AuthService
    @State private var isToggled = false
    @State private var isOpen = false
    
    @State var dragAmount = CGFloat(0)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VPNConnectView(isOpen: $isOpen)
                    .frame(width: geometry.size.width, height:geometry.size.height)
                
                CountrySelectorView()
                    .frame(width: geometry.size.width, height:geometry.size.height)
                    .offset(x: geometry.size.width - 5)
                }
            .background(
                LinearGradient(Color.backgroundStart, Color.backgroundEnd)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geometry.size.width*2, height: geometry.size.height)
                    .offset(x: geometry.size.width/2))
            .offset(x: isOpen ? -geometry.size.width + dragAmount : dragAmount)
            .gesture(DragGesture().onChanged { value in
                dragAmount = value.translation.width
            }.onEnded { value in
                dragAmount = 0
                if abs(value.translation.width) > (geometry.size.width - 50) / 2 {
                    if value.translation.width.sign == .plus {
                        isOpen = false
                    } else {
                        isOpen = true
                    }
                }
               
            })
        }//.scaleEffect(0.3)
    }
    
    func closePage() {
        withAnimation {
            isOpen = false
        }
    }
    func openPage(){
        withAnimation {
            isOpen = true
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().scaleEffect(1)
    }
}
