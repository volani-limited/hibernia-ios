//
//  MainView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI
import FirebaseRemoteConfig

struct HomeView: View {
    @RemoteConfigProperty(key: "serviceMessage", fallback: "") var serviceMessage: String
    @Binding var presentingLocationSelectorView: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("HiberniaVPN")
                    .fontWeight(.black)
                    .font(.custom("Comfortaa", size: 40))
                    .foregroundColor(.titleText)
                    .padding()
                
                VPNControlStatusContainerView()
                
                LocationSelectorItemView(presentingLocationSelectorView: $presentingLocationSelectorView)
                
                Text(serviceMessage)
            }
            .frame(height: geometry.size.height * 0.8)
        }
    }
}
