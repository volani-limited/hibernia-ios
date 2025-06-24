//
//  LocationSelectorRowView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI
import SwiftyPing

import FirebaseRemoteConfig

struct DestinationSelectorRowView: View {
    @RemoteConfigProperty(key: "destinationSelectorCheckmarks", fallback: true) var selectorCheckmarks: Bool
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @ScaledMetric(relativeTo: .title) private var dynamicTypeScaleFactor = 1
    
    var destination: VPNService.VPNDestination
    var allPings: [Double]
    var pingResult: Result<Double, PingError>?
    var isHighlighted: Bool
    
    var body: some View {
        HStack {
            Text(destination.displayedName)
                .font(.custom("Comfortaa", size: 24, relativeTo: .title))
                .foregroundStyle(Color.text)
            
            Spacer()
            
            Text("Nearest")
                .font(.custom("Comfortaa", fixedSize: 12))
                .foregroundStyle(Color.turquoise)
                .shadow(color: .turquoise, radius: 2)
                .opacity((try? pingResult?.get()) == (allPings.min() ?? 0) ? 1 : 0)
                //.offset(y: dynamicTypeSize.isAccessibilitySize ? 0 : 1)
            
            if let pingResult = pingResult {
                switch pingResult {
                case .success(let success):
                    if(dynamicTypeSize.isAccessibilitySize) {
                        VStack(alignment: .center, spacing: 12) {
                            CapsulePingGraphView(value: computePingProportion(ping: success, pings: allPings))
                                .frame(width: 13 * dynamicTypeScaleFactor, height: 16 * dynamicTypeScaleFactor)
                                .padding(.trailing)
                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                Text((success*1000).formatted(.number.precision(.fractionLength(0))))
                                    .font(.custom("Comfortaa", size: 16, relativeTo: .title2))
                                    .bold()
                                    .foregroundStyle(Color.text)
                                Text("ms")
                                    .font(.custom("Comfortaa", size: 12, relativeTo: .title2))
                                    .foregroundStyle(Color.text)
                            }
                        }
                    } else {
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            Text((success*1000).formatted(.number.precision(.fractionLength(0))))
                                .font(.custom("Comfortaa", size: 16, relativeTo: .title2))
                                .bold()
                                .foregroundStyle(Color.text)
                            Text("ms")
                                .font(.custom("Comfortaa", size: 12, relativeTo: .title2))
                                .foregroundStyle(Color.text)
                        }
                        CapsulePingGraphView(value: computePingProportion(ping: success, pings: allPings))
                            .frame(width: 13, height: 16)
                            .padding(.trailing)
                    }
                case .failure:
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(Color.red)
                        .padding(5)
                }
            } else {
                Spacer()
                ProgressView()
                    .padding(.trailing, 5)
                    .dynamicTypeSize(.large)
            }
            
            if selectorCheckmarks {
                Image(systemName: isHighlighted ? "checkmark.circle" : "circle")
                    .foregroundStyle(isHighlighted ? Color.turquoise : Color.text)
                    .shadow(color: isHighlighted ? Color.turquoise : Color.text, radius: 4)
                    .padding(5)
                    .background(NeumorphicShape(isHighlighted: isHighlighted, shape: Circle()))
                    .dynamicTypeSize(.large)
            }
        }
        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
        .minimumScaleFactor(0.4)
        .padding()
        .background(NeumorphicShape(isHighlighted: isHighlighted, shape: RoundedRectangle(cornerRadius: 15)))
    }
    
    func computePingProportion(ping: Double, pings: [Double]) -> Double {
        let minPing = pings.min()!
        let maxPing = pings.max()!
        
        return (ping - maxPing) / (minPing - maxPing)
    }
}


