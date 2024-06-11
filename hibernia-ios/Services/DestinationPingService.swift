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
    @Published var pingResults: [VPNDestination: Result<Double, PingError>?]
    @Published var preparingResults: Bool
    
    init() {
        pingResults = [VPNDestination: Result<Double, PingError>?]()
        preparingResults = false
        
        VPNDestination.allCases.forEach { destination in
            pingResults.updateValue(nil, forKey: destination)
        }
    }
    
    func pingAllDestinations() {
        preparingResults = true
        
        VPNDestination.allCases.forEach { destination in
            pingResults.updateValue(nil, forKey: destination)
        }
        
        Task {
            await withTaskGroup(of: (destination: VPNDestination, result: Result<Double, PingError>).self) { group in
                for destination in pingResults.keys {
                    group.addTask {
                        let hostname = destination.rawValue + "-1.vpn.hiberniavpn.com"
                        do {
                            let averagePing = try await self.getAveragePing(hostname: hostname, interval: 1, timeout: 2, attempts: 5)
                            return (destination: destination, .success(averagePing))
                        } catch let pingError as PingError {
                            return (destination: destination, .failure(pingError))
                        } catch {
                            fatalError("Unhandled error pinging destination \(destination.rawValue): \(error.localizedDescription)")
                        }
                    }
                }
                for await pingResult in group {
                    self.pingResults.updateValue(pingResult.result, forKey: pingResult.destination)
                }
                self.preparingResults = false
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
