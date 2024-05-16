//
//  LocationPingService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 15/05/2024.
//

import Foundation
import Combine

class LocationPingService: ObservableObject {
    @Published var pings: [VPNDestination: Double]
    @Published var pingProportions: [VPNDestination: Double]

    private var pingPublishers: [VPNDestination: SwiftyPingPublisher]
    private var subscriptions: Set<AnyCancellable>
    
    init() {
        pings = [VPNDestination: Double]()
        pingProportions = [VPNDestination: Double]()
        
        pingPublishers = [VPNDestination: SwiftyPingPublisher]()
        subscriptions = Set<AnyCancellable>()
        
        for destination in VPNDestination.allCases {
            pingProportions[destination] = 0.0
            pings[destination] = 0.0
        }
    }
    
    func beginUpdating() {
        for destination in pings.keys {
            let hostname = destination.rawValue + "-1.vpn.hiberniavpn.com"
            
            pingPublishers[destination] = SwiftyPingPublisher(hostname: hostname, interval: 1.5, timeout: 4)
            pingPublishers[destination]!.begin()
            
            pingPublishers[destination]!
                .sink { value in
                    self.pings[destination] = value
                }
                .store(in: &subscriptions)
        }
        
        $pings.sink { pings in
            let lowestPing = pings.values.min()!
            let highestPing = pings.values.max()!
            
            self.pingProportions = Dictionary(uniqueKeysWithValues: self.pingProportions.map { key, value in
                let ping = pings[key]!
                let pingProportion = (ping - highestPing) / (lowestPing - highestPing)
                
                return (key, pingProportion)
            })
        }
        .store(in: &subscriptions)
    }
}
