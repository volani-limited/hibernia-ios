//
//  CountrySelectorView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

struct CountrySelectorView: View {
    @EnvironmentObject var vpnService: VPNService
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    VStack(alignment: .center) { // Present VPN destinations as defined in enum and set selected destination on tap
                        ForEach(VPNDestination.allCases, id: \.self) { destination in
                            Text(destination.displayed)
                                .font(.custom("Comfortaa", size: 20))
                                .foregroundColor(colorScheme == .dark ? .highlightStart : .highlightEnd)
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
                    }.frame(maxWidth: .infinity)
                }.frame(width: geometry.size.width, height: geometry.size.height - 105)
            }
        }
    }
}

struct CountrySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CountrySelectorView()
    }
}
