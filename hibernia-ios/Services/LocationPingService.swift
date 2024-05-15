//
//  LocationPingService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 15/05/2024.
//

import Foundation
import Combine

class LocationPingService: ObservableObject {
    @Published var pingProportions: [VPNDestination: Double]
    
    private var pingSubscriptions: [VPNDestination: AnyCancellable?]
    
    init() {
        pingProportions = [VPNDestination: Double]()
        
        pingSubscriptions =  [VPNDestination: AnyCancellable?]()
        
        for destination in VPNDestination.allCases {
            pingProportions[destination] = 0.0
            pingSubscriptions[destination] = nil
        }
    }
    
    func beginUpdating() {
        for destination in pingSubscriptions.keys {
            let hostname = destination.rawValue + "-1.hiberniavpn.com"
            pingSubscriptions[destination] = SimplePingPublisher(hostName: hostname)
                .sink {
                    
                }
            
            
        }
    }
}
