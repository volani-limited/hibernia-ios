//
//  NeumorphicViews.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

struct NeumorphicShape<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        if isHighlighted {
            if #available(iOS 16.0, *) {
                shape
                    .fill(
                        LinearGradient(Color.backgroundStart, Color.backgroundEnd)
                            .shadow(.inner(color: .backgroundEnd, radius: 3, x: 3, y: 3))
                            .shadow(.inner(color: .backgroundStart, radius: 3, x: -3, y: -3))
                    )
            } else {
                shape
                    .fill(LinearGradient(Color.backgroundStart, Color.backgroundEnd))
                    .overlay(
                        shape
                            .stroke(Color.backgroundEnd, lineWidth: 3)
                            .blur(radius: 2.5)
                            .offset(x: 2, y: 2)
                            .mask(shape.fill(LinearGradient(Color.black, Color.clear)))
                    )
                    .overlay(
                        shape
                            .stroke(Color.backgroundStart, lineWidth: 5)
                            .blur(radius: 2.5)
                            .offset(x: -2, y: -2)
                            .mask(shape.fill(LinearGradient(Color.clear, Color.black)))
                    )
            }
        } else {
            shape
                .fill(LinearGradient(Color.backgroundStart, Color.backgroundEnd))
                .shadow(color: Color.backgroundEnd, radius: 10, x: 10, y: 10)
                .shadow(color: Color.backgroundStart, radius: 10, x: -5, y: -5)
        }
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
                    .onAppear {
                        isAnimating = false
                    }
            } else if isProcessing {
                shape.fill(LinearGradient(Color.backgroundStart, Color.backgroundEnd))
                .overlay(
                    shape.trim(from: 0.0, to: 0.7)
                        .stroke(LinearGradient(Color.highlightStart, Color.highlightEnd), lineWidth: 5)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
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
                    .shadow(color: Color.backgroundEnd, radius: 10, x: 10, y: 10).onAppear {
                        isAnimating = false
                    }
            }
        }
    }
}

struct MainButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    var isProcessing: Bool
    var isDepressed: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
        .background(
            ColorfulBackground(isHighlighted: isDepressed, isProcessing: isProcessing, shape: Circle())
        )
        .opacity(isEnabled ? 1 : 0.4)
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .padding(.leading, 45)
            .padding(.trailing, 45)
            .background(NeumorphicShape(isHighlighted: (configuration.isPressed || !isEnabled), shape: Capsule()))
    }
}

struct NeumorphicPreviews: PreviewProvider {
    static var previews: some View {
        NeumorphicShape(isHighlighted: true, shape: RoundedRectangle(cornerRadius: 5)).frame(width: 300, height: 60)
    }
}
