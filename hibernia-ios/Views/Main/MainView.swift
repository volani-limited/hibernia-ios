//
//  MainView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct MainView: View {
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
            }
            .frame(height: geometry.size.height * 0.8)
        }
    }
}
