//
//  MainView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct MainView: View {
    @Binding var presentingLocationSelectorView: Bool
    
    @State private var presentingSubscribeModalView: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("HiberniaVPN")
                    .bold()
                    .font(.custom("Comfortaa", size: 40))
                    .foregroundColor(.titleText)
                    .padding()
                
                VPNControlStatusContainerView(presentingSubscribeModalView: $presentingSubscribeModalView)
                
                LocationSelectorItemView(presentingLocationSelectorView: $presentingLocationSelectorView)
                
            }
            .frame(height: geometry.size.height * 0.8)
            .sheet(isPresented: $presentingSubscribeModalView) {
                SubscribeModalView()
            }
        }
    }
}
