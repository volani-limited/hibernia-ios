//
//  CapsulePingGraphView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 15/05/2024.
//

import SwiftUI

struct CapsulePingGraphView: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            HStack (alignment: .bottom, spacing: 4) {
                Capsule()
                    .frame(width: geometry.size.width / 3, height: geometry.size.height / 3)
                    .foregroundStyle(Color.turquoise)
                    .shadow(color: Color.turquoise, radius: 1)
                Capsule()
                    .frame(width: geometry.size.width / 3, height: geometry.size.height * 2/3)
                    .foregroundStyle(value >= 0.33 ? Color.turquoise : Color.text)
                    .shadow(color: value >= 0.33 ? Color.turquoise : Color.clear, radius: 1)
                Capsule()
                    .frame(width: geometry.size.width / 3, height: geometry.size.height)
                    .foregroundStyle(value >= 0.66 ? Color.turquoise : Color.text)
                    .shadow(color: value >= 0.66 ? Color.turquoise : Color.clear, radius: 1)
            }
        }
    }
}

#Preview {
    CapsulePingGraphView(value: 0.3)
}
