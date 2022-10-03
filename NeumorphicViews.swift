//
//  NeumorphicViews.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

struct NeumorphicBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        shape
            .fill(LinearGradient(.backgroundStart, .backgroundEnd))
            .shadow(color: Color.backgroundStart, radius: 10, x: 5, y: 5)
            .shadow(color: Color.backgroundEnd, radius: 10, x: -5, y: -5)
    }
}

struct ColorfulBackground<S: Shape>: View {
    var isHighlighted: Bool
    var isProcessing: Bool
    var shape: S
    
    @State private var isAnimating =  false

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.highlightEnd, Color.highlightStart))
                    .overlay(shape.stroke(LinearGradient(Color.highlightStart, Color.highlightEnd), lineWidth: 5).shadow(color: Color.highlightStart, radius: 2))
                    .shadow(color: Color.backgroundStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.backgroundEnd, radius: 10, x: -5, y: -5)
            } else if isProcessing {
                shape.fill(LinearGradient(Color.backgroundStart, Color.backgroundEnd))
                .overlay(
                    shape.trim(from: 0.0, to: 0.7)
                        .stroke(LinearGradient(Color.highlightStart, Color.highlightEnd), lineWidth: 5)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                        .onAppear {
                            isAnimating = true
                        }
                )
                .shadow(color: Color.backgroundStart, radius: 10, x: -10, y: -10)
                .shadow(color: Color.backgroundEnd, radius: 10, x: 10, y: 10)
                .opacity(0.7)
            } else {
                shape
                    .fill(LinearGradient(Color.backgroundStart, Color.backgroundEnd))
                    .overlay(shape.stroke(LinearGradient(Color.highlightStart, Color.highlightEnd), lineWidth: 5).shadow(color: Color.highlightStart, radius: 1))
                    .shadow(color: Color.backgroundStart, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.backgroundEnd, radius: 10, x: 10, y: 10)
                    
            }
        }
    }
}

struct MainButtonToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) var isEnabled
    var isLoading: Bool = false
    @State private var isProcessing: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            isProcessing = true
            //configuration.isOn.toggle() // start process
        }) {
            configuration.label
                .padding(30)
                .contentShape(Circle())
        }
        .background(
            ColorfulBackground(isHighlighted: configuration.isOn, isProcessing: isProcessing, shape: Circle())
        )
        .opacity(isEnabled ? 1 : 0.4)
    }
}
/*
struct NeumorphicButtonStyle<S: Shape>: ButtonStyle {
    var shape: S
    func makeBody(configuration: Self.Configuration) -> some View {
        if configuration.isPressed {
            shape
                .fill(Color.backgroundStart)
                .overlay(
                    shape
                        .stroke(Color.gray, lineWidth: 4)
                        .blur(radius: 4)
                        .offset(x: 2, y: 2)
                        .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                )
                .overlay(
                    shape
                        .stroke(Color.white, lineWidth: 8)
                        .blur(radius: 4)
                        .offset(x: -2, y: -2)
                        .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                )
        } else {
            configuration.label
            .fill(Color.backgroundStart)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: -5, y: -5)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: 10, y: 10)
        }
    }
}
*/
