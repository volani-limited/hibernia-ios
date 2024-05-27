//
//  LocationSelectorRowView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI
import SwiftyPing

struct LocationSelectorRowView: View {
    var destination: VPNDestination
    var pingResult: Result<(ping: Double, pingProportion: Double, isNearest: Bool), PingError>?
    var isHighlighted: Bool
    
    var body: some View {
        HStack {
            HStack(alignment: .center, spacing: 5) {
                Text(destination.displayed)
                    .font(.custom("Comfortaa", size: 24))
                    .foregroundStyle(Color.text)
                Text("Nearest")
                    .font(.custom("Comfortaa", size: 12))
                    .foregroundStyle(Color.turquoise)
                    .shadow(color: .turquoise, radius: 2)
                    .opacity((try? pingResult?.get())?.isNearest ?? false ? 1 : 0)
                    .offset(y: 1)
            }
            
            Spacer()
            
            if let pingResult = pingResult {
                switch pingResult {
                case .success(let success):
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text((success.ping*1000).formatted(.number.precision(.fractionLength(0))))
                            .font(.custom("Comfortaa", size: 16))
                            .bold()
                            .foregroundStyle(Color.text)
                        Text("ms")
                            .font(.custom("Comfortaa", size: 12))
                            .foregroundStyle(Color.text)
                    }
                    CapsulePingGraphView(value: success.pingProportion)
                        .frame(width: 13, height: 16)
                        .padding(.trailing)
                case .failure:
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(Color.red)
                        .padding(5)
                }
            } else {
                Spacer()
                ProgressView()
                    .padding(.trailing, 5)
            }
            
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


