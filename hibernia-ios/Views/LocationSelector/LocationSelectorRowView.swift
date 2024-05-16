//
//  LocationSelectorRowView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct LocationSelectorRowView: View {
    var location: VPNDestination
    
    var ping: Double
    var pingGraphValue: Double

    var isHighlighted: Bool
    var isNearest: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Text(location.displayed.prefix(1))
                    .font(.custom("Comfortaa", size: 24))
                Text(location.displayed.suffix(from: location.displayed.index(location.displayed.startIndex, offsetBy: 1)))
                    .font(.custom("Comfortaa", size: 24))
                    .foregroundStyle(isNearest ? Color.turquoise : Color.text)
                    .shadow(color: isNearest ? .turquoise : .clear, radius: 5)
            }
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text((ping*1000).formatted(.number.precision(.fractionLength(0))))
                    .font(.custom("Comfortaa", size: 16))
                    .bold()
                    .foregroundStyle(Color.text)
                Text("ms")
                    .font(.custom("Comfortaa", size: 12))
                    .foregroundStyle(Color.text)
            }
            
            CapsulePingGraphView(value: pingGraphValue)
                .frame(width: 13, height: 16)
                .padding(.trailing)
            
            Image(systemName: isHighlighted ? "checkmark.circle" : "circle")
                .foregroundStyle(isHighlighted ? Color.turquoise : Color.text)
                .shadow(color: isHighlighted ? Color.turquoise : Color.text, radius: 4)
                .padding(5)
                .background(NeumorphicShape(isHighlighted: isHighlighted, shape: Circle()))
        }
        .padding()
        .background(NeumorphicShape(isHighlighted: isHighlighted, shape: RoundedRectangle(cornerRadius: 15)))
    }
}


