//
//  LocationSelectorItemView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct LocationSelectorItemView: View {
    @EnvironmentObject var vpnService: VPNService
    @Binding var presentingLocationSelectorView: Bool
    
    var body: some View {
        VStack {
            Text("Location")
                .font(.custom("Comfortaa", size: 17))
                .foregroundStyle(Color.titleText)
                .bold()
            HStack() {
                Text(vpnService.destination.displayed)
                    .font(.custom("Comfortaa", size: 16))
                    .foregroundStyle(Color.text)
                    .bold()
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    withAnimation {
                        presentingLocationSelectorView = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.titleText)
                        .padding()
                }
                .buttonStyle(NeumorphicButtonStyle(shape: Circle()))
            }
            .padding(8)
            .background(
                NeumorphicShape(isHighlighted: true, shape: Capsule())
            )
        }
    }
}
