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
                        let hostname = destination.hostname

                        do {
                            let averagePing = try await Self.getAveragePing(hostname: hostname)
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
    
    public static func ping(hostname:  String, interval: Double, timeout: Double, attempts: Int) async throws -> PingResult {
        let manager = try SwiftyPing(host: hostname, configuration: PingConfiguration(interval: interval, with: timeout), queue: DispatchQueue.global(qos: .userInteractive))
        
        manager.targetCount = attempts
            
        return try await withCheckedThrowingContinuation { continuation in
            manager.finished = { pingResult in
                continuation.resume(returning: pingResult)
            }
            try! manager.startPinging()
        }
    }
    
    private static func getAveragePing(hostname:  String) async throws -> Double {
        let pingResult = try await Self.ping(hostname: hostname, interval: 1, timeout: 2, attempts: 5)
        
        guard let roundtrip = pingResult.roundtrip else {
            throw PingError.requestError
        }
        
        return roundtrip.average
    }
}

extension Result {
    var isSuccess: Bool { if case .success = self { return true } else { return false } }
}
