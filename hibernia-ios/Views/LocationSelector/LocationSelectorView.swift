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
    
    @StateObject var destinationPingService = DestinationPingService()

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

                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        destinationPingService.pingAllDestinations()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.text)
                    }
                    .padding()
                    .buttonStyle(NeumorphicButtonStyle(shape: Circle()))
                    .disabled(destinationPingService.processingFirstResult)
                    .opacity(destinationPingService.processingFirstResult ? 0 : 1)
                }
            }
            ScrollView {
                VStack(alignment: .center) {
                    ForEach(VPNDestination.allCases, id: \.self) { destination in
                        LocationSelectorRowView(destination: destination, pingResult: destinationPingService.pingResults[destination]!, isHighlighted: vpnService.destination == destination)
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
        .onAppear {
            destinationPingService.pingAllDestinations()
        }
    }
}
