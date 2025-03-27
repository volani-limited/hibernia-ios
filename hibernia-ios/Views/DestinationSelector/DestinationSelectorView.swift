//
//  LocationSelectorView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI
import SwiftyPing
import FirebaseRemoteConfig

struct DestinationSelectorView: View {
    @EnvironmentObject var vpnService: VPNService
    @EnvironmentObject var rcService: RemoteConfigService

    @RemoteConfigProperty(key: "destinationSelectorDisabledForPingError", fallback: false) var destinationSelectorDisabledForPingError: Bool
    
    @Binding var presenting: Bool
    
    @StateObject var destinationPingService: DestinationPingService = DestinationPingService()

    var body: some View {
        VStack {
            ZStack {
                Text("Destinations")
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
                        
                        Task {
                            await destinationPingService.pingDestinations(destinations: rcService.remoteConfiguration.destinations)
                        }
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
                VStack(alignment: .center) { // TODO: add paywall stuff
                    HStack {
                        Text("Classic")
                            .font(.custom("Comfortaa", size: 22))
                            .foregroundStyle(Color.text)
                            .padding()
                        Spacer()
                    }

                    ForEach(rcService.remoteConfiguration.destinations.filter { $0.type == .classic}) { destination in
                        DestinationSelectorRowView(destination: destination, allPings: destinationPingService.pingResults.values.compactMap { try? $0.get() }, pingResult: destinationPingService.pingResults[destination], isHighlighted: vpnService.selectedDestination == destination)
                            .onTapGesture {
                                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                                feedbackGenerator.impactOccurred()
                                vpnService.selectedDestination = destination  
                            }
                            .disabled((destinationPingService.pingResults[destination]?.isSuccess != true) && destinationSelectorDisabledForPingError)
                    }
                    
                    HStack {
                        Text("Dedicated")
                            .font(.custom("Comfortaa", size: 22))
                            .foregroundStyle(Color.text)
                            .padding()
                        Spacer()
                    }
                    
                    ForEach(rcService.remoteConfiguration.destinations.filter { $0.type == .dedicated}) { destination in
                        DestinationSelectorRowView(destination: destination, isHighlighted: vpnService.selectedDestination == destination)
                            .onTapGesture {
                            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                            feedbackGenerator.impactOccurred()
                            vpnService.selectedDestination = destination
                        }
                    }
                }
                .disabled(vpnService.status != .disconnected)
                .padding()
                .padding(.top, 10)

                if vpnService.status != .disconnected {
                    Text("Please disconnect before changing destinations")
                        .font(.custom("Comfortaa", size: 15))
                        .foregroundStyle(Color.text)
                }
            }
        }
        .task {
            await destinationPingService.pingDestinations(destinations: rcService.remoteConfiguration.destinations)
        }
    }
}
