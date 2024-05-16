//
//  SwiftyPingPublisher.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 16/05/2024.
//

import Foundation
import Combine
import SwiftyPing

class SwiftyPingPublisher: Publisher, Cancellable {
    typealias Output = Double
    typealias Failure = Never
    
    var hostname: String
    
    private var manager: SwiftyPing
    private let passthroughSubject: PassthroughSubject<Output, Failure>
    
    init(hostname: String, interval: Double, timeout: Double) { //TODO: MUST update to throwing initalizer to handle errors if hosts are down
        
        self.hostname = hostname
        
        manager = try! SwiftyPing(host: hostname, configuration: PingConfiguration(interval: interval, with: timeout), queue: DispatchQueue.global())
        
        self.passthroughSubject = PassthroughSubject<Output, Failure>()
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Double == S.Input {
        passthroughSubject.receive(subscriber: subscriber)
    }
    
    func begin() { // TODO: Will leave as seperate begin, but could move to init depending on later implementation of location ping service
        try! manager.startPinging() // TODO: Wrap as throwing function?
        
        manager.observer = { response in
            let duration = response.duration
            self.passthroughSubject.send(duration)
        }
    }
    
    func cancel() {
        manager.observer = nil
        manager.stopPinging()
    }
}
