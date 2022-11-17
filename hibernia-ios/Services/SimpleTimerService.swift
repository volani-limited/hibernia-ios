//
//  TimerService.swift
//  v-rowcoach
//
//  Created by Oliver Bevan on 10/01/2022.
//

import Foundation

class SimpleTimerService {
    //MARK: Published varibles
    @Published private(set) var elapsedTime: TimeInterval = 0 // Setup published varibles
    @Published private(set) var running: Bool = false
    
    private var startTime: Date? // instantiate internal private varibles
    private var accumulatedTime: TimeInterval = 0
    
    private var timer: Timer?
    
    func start() {
        startTime = Date() // record start time
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime = self.getElapsedTime() // start timer updating elapsedTime every 0.1s
        }
        running = true
    }
    
    func stop() {
        self.timer?.invalidate() // cancel the timer
        accumulatedTime = getElapsedTime() // set the accumulated time
        
        self.timer = nil
        self.startTime = nil // reset values
        running = false
        
    }
    
    func reset(){
        if !running { // if not running, reset values
            elapsedTime = 0
            accumulatedTime = 0
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    private func getElapsedTime() -> TimeInterval { // calculate elapsed time with time since start plus time accumulated in previous start/stops
        return -(startTime?.timeIntervalSinceNow ?? 0) + accumulatedTime
    }
}
