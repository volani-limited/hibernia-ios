//
//  ScaleEffectButtonStyle.swift
//
//
//  Created by Oliver Bevan on 03/03/2024.
//

import SwiftUI

struct ScaleEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
