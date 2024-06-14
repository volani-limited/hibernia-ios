//
//  ColorExtension.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 01/10/2022.
//

import Foundation
import SwiftUI

extension Color {
    static let background = Color("background")
    static let vBlue = Color("blue")
    static let vRed = Color("red")
    static let vOrange = Color("orange")
    static let text = Color("text")
    static let titleText = Color("titleText")
    static let turquoise = Color("turquoise")
    static let darkShadow = Color("darkShadow")
    static let lightShadow = Color("lightShadow")
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
