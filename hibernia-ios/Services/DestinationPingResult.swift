//
//  DestinationPingResult.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/05/2024.
//

import Foundation
import SwiftyPing

class DestinationPingResult: ObservableObject {
    @Published var pingResult: (ping: Double, pingProportion: Double)? // Note: Have decided to publish optional tuple as opposed to propagating error with Result. Error isn't going to be displayed to user so no need to propogate

    var destination: VPNDestination
    
    init(destination: VPNDestination) {
        self.destination = destination
    }
}
