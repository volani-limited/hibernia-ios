//
//  MainView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct HomeView: View {
    @Binding var presentingLocationSelectorView: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Text("HiberniaVPN")
                    .fontWeight(.black)
                    .font(.custom("Comfortaa", size: 40))
                    .foregroundStyle(Color.titleText)
                    .padding()
                
                VPNControlStatusContainerView()
                
                ServiceMessageView()
                    .padding()
                
                LocationSelectorItemView(presentingLocationSelectorView: $presentingLocationSelectorView)
                
            }
            .frame(height: geometry.size.height * 0.8)
        }
    }
}
