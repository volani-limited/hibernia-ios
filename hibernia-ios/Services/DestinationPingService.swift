//
//  DestinationPingService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 15/05/2024.
//

import Foundation
import SwiftyPing

@MainActor
class DestinationPingService: ObservableObject {
    //@Published var pingResults: [DestinationPingResult] Updating a single ping will require all pings to be updated (as the new ping has the potential to change the min/max and therefore all ping proportions
    
    @Published var pingResults: [VPNDestination: Result<Double, PingError>?]
    @Published var processingFirstResult: Bool
    
    init() {
        pingResults = [VPNDestination: Result<Double, PingError>?]()
        processingFirstResult = false
        
        VPNDestination.allCases.forEach { destination in
            pingResults.updateValue(nil, forKey: destination)
        }
    }
    
    func pingAllDestinations() {
        processingFirstResult = true
        
        VPNDestination.allCases.forEach { destination in
            pingResults.updateValue(nil, forKey: destination)
        }
        
        Task {
            await withTaskGroup(of: Double.self) { group in
                for destination in pingResults.keys {
                    let hostname = destination.rawValue + "-1.vpn.hiberniavpn.com"
                    do {
                        let averagePing = try await getAveragePing(hostname: hostname, interval: 1, timeout: 2, attempts: 5)
                        
                        pingResults[destination] = .success(averagePing)
                        processingFirstResult = false
                    } catch let error as PingError {
                        pingResults[destination] = .failure(error)
                    } catch {
                        fatalError("Unhandled error pinging: \(error)")
                    }
                }
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
            try! manager.startPinging()
        }
    }
}

extension Result {
    var isSuccess: Bool { if case .success = self { return true } else { return false } }
}