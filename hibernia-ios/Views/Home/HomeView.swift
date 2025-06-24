//
//  MainView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct HomeView: View {
    @Binding var presentingDestinationSelectorView: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Text("HiberniaVPN")
                    .fontWeight(.black)
                    .font(.custom("Comfortaa", fixedSize: 40))
                    .foregroundStyle(Color.titleText)
                    .padding()
                
                VPNControlStatusContainerView()
                
                ServiceMessageView()
                    .padding()
                
                DestinationSelectorItemView(presentingDestinationSelectorView: $presentingDestinationSelectorView)
                
            }
            .frame(height: geometry.size.height * 0.8)
        }
    }
}
