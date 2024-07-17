//
//  LocationSelectorView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI
import SwiftyPing

struct DestinationSelectorView: View {
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
                            .padding()
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
                            .padding()
                    }
                    .padding()
                    .buttonStyle(NeumorphicButtonStyle(shape: Circle()))
                    .disabled(destinationPingService.preparingResults || vpnService.status != .disconnected)
                    .opacity(destinationPingService.preparingResults || vpnService.status != .disconnected ? 0 : 1)
                }
            }
            ScrollView {
                VStack(alignment: .center) {
                    ForEach(VPNDestination.allCases, id: \.self) { destination in
                        DestinationSelectorRowView(destination: destination, allPings: destinationPingService.pingResults.values.compactMap { try? $0?.get() }, pingResult: destinationPingService.pingResults[destination]!, isHighlighted: vpnService.destination == destination)
                            .onTapGesture {
                                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                                feedbackGenerator.impactOccurred()
                                vpnService.destination = destination
                            }
                    }
                }
                .disabled(vpnService.status != .disconnected)
                .padding()
                .padding(.top, 10)
                if vpnService.status != .disconnected {
                    Text("Please disconnect before changing locations")
                        .font(.custom("Comfortaa", size: 15))
                        .foregroundStyle(Color.text)
                }
            }
        }
        .onAppear {
            destinationPingService.pingAllDestinations()
        }
    }
}
