//
//  TabBarSelectorView.swift
//  hiberniaui
//
//  Created by Oliver Bevan on 03/03/2024.
//

import SwiftUI

struct TabBarSelectorView: View {
    @Binding var inLeftHandPosition: Bool

    var body: some View {
        HStack (spacing: 30) {
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                inLeftHandPosition = false
            } label: {
                Image(systemName: "house")
                    .foregroundStyle(inLeftHandPosition ? Color.text : Color.turquoise)
                    .shadow(color: inLeftHandPosition ? Color.text : Color.turquoise, radius: 5, x: 0, y: 0)
                    .scaleEffect(1.6)
                    .hoverEffect()
            }
            .buttonStyle(ScaleEffectButtonStyle())

            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                inLeftHandPosition = true
            } label: {
                Image(systemName: "gear")
                    .foregroundStyle(!inLeftHandPosition ? Color.text : Color.turquoise)
                    .shadow(color: !inLeftHandPosition ? Color.text : Color.turquoise, radius: 5, x: 0, y: 0)
                    .scaleEffect(1.6)
                    .hoverEffect()
            }
            .buttonStyle(ScaleEffectButtonStyle())
        }
        .padding()
        .background(NeumorphicShape(isHighlighted: false, shape: Capsule()))
    }
}

