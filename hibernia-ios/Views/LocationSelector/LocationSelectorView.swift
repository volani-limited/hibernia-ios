//
//  LocationSelectorView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct LocationSelectorView: View {
    @EnvironmentObject var vpnService: VPNService
    @Binding var presenting: Bool

    var body: some View {
        VStack {
            ZStack {
                Text("Locations")
                    .bold()
                    .font(.custom("Comfortaa", size: 30))
                    .foregroundColor(.titleText)
                HStack {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation {
                            presenting = false
                        }
                    } label: {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(.text)
                    }
                    .padding()
                    .buttonStyle(NeumorphicButtonStyle(shape: Circle()))
                    Spacer()
                }
            }
            ScrollView {
                VStack(alignment: .center) {
                   ForEach(VPNDestination.allCases, id: \.self) { destination in
                       LocationSelectorRowView(location: destination, isHighlighted: vpnService.destination == destination)
                           .onTapGesture {
                               let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                               feedbackGenerator.impactOccurred()
                               vpnService.destination = destination
                           }
                   }
               }
            .padding()
            .padding(.top, 10)
            }
        }
    }
}
