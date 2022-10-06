//
//  CountrySelectorView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

struct CountrySelectorView: View {
    @EnvironmentObject var vpnService: VPNService
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .center) {
                    ForEach(VPNDestination.allCases, id: \.self) { destination in
                        Text(destination.rawValue)
                            .font(.custom("Comfortaa", size: 20))
                            .foregroundColor(.highlightEnd)
                            .padding()
                            .background(
                                NeumorphicShape(isHighlighted: destination == vpnService.destination, shape: RoundedRectangle(cornerRadius: 5))
                                    .frame(width: geometry.size.width - 50)
                            )
                            .onTapGesture {
                                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                                feedbackGenerator.impactOccurred()
                                vpnService.destination = destination
                            }
                    }
                    Spacer()
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct CountrySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CountrySelectorView()
    }
}
