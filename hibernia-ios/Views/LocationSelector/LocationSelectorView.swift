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
                Text("Location")
                HStack {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation {
                            presenting = false
                        }
                    } label: {
                        Image(systemName: "arrow.backward") //TODO: use in neumorphic button circle
                            .foregroundColor(.white)
                    }
                    .padding()
                    .buttonStyle(NeumorphicButtonStyle(shape: Circle()))
                    Spacer()
                }
            }
            ScrollView {
                VStack(alignment: .center) {
                   ForEach(VPNDestination.allCases, id: \.self) { destination in
                       Text(destination.displayed)
                           .font(.custom("Comfortaa", size: 20))
                           .padding()
                           .onTapGesture {
                               let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                               feedbackGenerator.impactOccurred()
                               vpnService.destination = destination
                           }
                   }
               }
            }
        }
    }
}
