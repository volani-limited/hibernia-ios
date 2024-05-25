//
//  DestinationPingService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 15/05/2024.
//

import Foundation
import SwiftyPing

class DestinationPingService: ObservableObject {
    @Published var pingResults: [DestinationPingResult]
    
    init() {
        pingResults = VPNDestination.allCases.map { return DestinationPingResult(destination: $0) }
    }
    
    func pingAllDestinations() async {
        let pings = pingResults.map { }

        pings = pings.map {
            do {
                let averagePing = try getAveragePing(hostname: $0.destination + "-1.hiberniavpn.com", interval: 1, timeout: 2, attempts: 5)
                
            }
        }
    }
    
    private func getAveragePing(hostname:  String, interval: Double, timeout: Double, attempts: Int) async throws -> Double {
        let manager = try SwiftyPing(host: hostname, configuration: PingConfiguration(interval: interval, with: timeout), queue: DispatchQueue.global())
        
        manager.targetCount = attempts
            
        return try await withCheckedThrowingContinuation { continuation in
                manager.finished = { pingResult in
                    guard let roundtrip = pingResult.roundtrip else {
                        continuation.resume(throwing: PingError.requestError)
                        return
                    }
                    continuation.resume(returning: roundtrip.average)
            }
        }
    }
}
