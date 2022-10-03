//
//  ColorExtension.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 01/10/2022.
//

import Foundation
import SwiftUI

extension Color {
    static let backgroundStart = Color("vBackgroundStart")
    static let backgroundEnd = Color("vBackgroundEnd")
    
    static let highlightStart = Color("vHighlightStart")
    static let highlightEnd = Color("vHighlightEnd")
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
