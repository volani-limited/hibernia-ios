//
//  NeumorphicViews.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

// MARK: Neumorphic view modifiers/shape, using iOS 16.4+ shadow

struct NeumorphicShape<S: Shape>: View {
    var isHighlighted: Bool = false
    var shape: S

    var body: some View {
        if isHighlighted {
            shape
                .fill(
                    Color.background
                        .shadow(.inner(color: Color.darkShadow, radius: 3, x: 3, y: 3))
                        .shadow(.inner(color: Color.lightShadow, radius: 3, x: -3, y: -3))
                )
        } else {
            shape
                .fill(Color.background)
                .shadow(color: Color.darkShadow, radius: 10, x: 10, y: 10)
                .shadow(color: Color.lightShadow, radius: 10, x: -5, y: -5)
        }
    }
}

struct NeumorphicButtonStyle<S: Shape>: ButtonStyle {
    var shape: S
    var isHighlighted: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed || isHighlighted {
                        shape.fill(
                            Color.background
                                .shadow(.inner(color: Color.darkShadow, radius: 3, x: 3, y: 3))
                                .shadow(.inner(color: Color.lightShadow, radius: 3, x: -3, y: -3))
                        )
                    } else {
                        shape
                            .fill(Color.background)
                            .shadow(color: Color.darkShadow, radius: 10, x: 10, y: 10)
                            .shadow(color: Color.lightShadow, radius: 10, x: -5, y: -5)
                    }
                }
            )
            .animation(.linear(duration: 0.08), value: configuration.isPressed)
        }
}

// MARK: Neumorpic main button, using legacy shadows

struct NeumorphicMainButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    var isProcessing: Bool
    var isDepressed: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .contentShape(Circle())
        .background(
            NeumorphicMainButtonBackground(isHighlighted: isDepressed, isProcessing: isProcessing, shape: Circle())
        )
    }
}


struct NeumorphicMainButtonBackground<S: Shape>: View {
    var isHighlighted: Bool
    var isProcessing: Bool
    var shape: S

    @State private var isAnimating =  false

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.vBlue, Color.turquoise))
                    .overlay(shape.stroke(LinearGradient(Color.turquoise, Color.vBlue), lineWidth: 5).shadow(color: Color.turquoise, radius: 2))
                    .shadow(color: Color.lightShadow, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkShadow, radius: 10, x: -5, y: -5)
                    .onAppear {
                        isAnimating = false
                    }
            } else if isProcessing {
                shape
                    .fill(Color.background)
                    .overlay(
                        shape.trim(from: 0.0, to: 0.8)
                            .stroke(LinearGradient(Color.turquoise, Color.vBlue), lineWidth: 5)
                            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                            .onAppear {
                                isAnimating = true
                            }
                    )
                    .shadow(color: Color.lightShadow, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.darkShadow, radius: 10, x: 10, y: 10)
                    .opacity(0.7)
            } else {
                shape
                    .fill(Color.background)
                    .overlay(shape.stroke(LinearGradient(Color.turquoise, Color.vBlue), lineWidth: 5)
                        .shadow(color: Color.turquoise, radius: 1))
                    .shadow(color: Color.lightShadow, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.darkShadow, radius: 10, x: 10, y: 10)
                    .onAppear {
                        isAnimating = false
                    }
            }
        }
    }
}
