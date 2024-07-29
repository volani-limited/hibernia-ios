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
    @Published var pingResults: [VPNService.VPNDestination: Result<Double, PingError>]
    @Published var preparingResults: Bool
    
    init() {
        pingResults = [VPNService.VPNDestination: Result<Double, PingError>]()
        preparingResults = false
    }
    
    func pingDestinations(destinations: [VPNService.VPNDestination]) async {
        preparingResults = true
        
        self.pingResults.removeAll()
        
        await withTaskGroup(of: (destination: VPNService.VPNDestination, result: Result<Double, PingError>).self) { group in
            for destination in destinations {
                group.addTask {
                    let hostname = destination.id + ".vpn.hiberniavpn.com"

                    do {
                        let averagePing = try await Self.getAveragePing(hostname: hostname)
                        return (destination: destination, .success(averagePing))
                    } catch let pingError as PingError {
                        return (destination: destination, .failure(pingError))
                    } catch {
                        fatalError("Unhandled error pinging destination \(destination.id): \(error.localizedDescription)")
                    }
                }
            }
            for await pingResult in group {
                self.pingResults[pingResult.destination] = pingResult.result
            }
            self.preparingResults = false
        }
    }
    
    public static func ping(hostname: String, interval: Double, timeout: Double, attempts: Int) async throws -> PingResult {
        let manager = try SwiftyPing(host: hostname, configuration: PingConfiguration(interval: interval, with: timeout), queue: DispatchQueue.global(qos: .userInteractive))
        
        manager.targetCount = attempts
            
        return try await withCheckedThrowingContinuation { continuation in
            manager.finished = { pingResult in
                continuation.resume(returning: pingResult)
                
                manager.finished = nil
            }
            do {
                try manager.startPinging()
            } catch {
                continuation.resume(throwing: error)
            }
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
