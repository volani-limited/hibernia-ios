//
//  LocationSelectorRowView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct LocationSelectorRowView: View {
    var location: VPNDestination
    var pingGraphValue: Double
    var isHighlighted: Bool
    
    var body: some View {
        HStack {
            Text(location.displayed)
                .font(.custom("Comfortaa", size: 24))
                .foregroundStyle(Color.text)
            
            Spacer()
            
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


