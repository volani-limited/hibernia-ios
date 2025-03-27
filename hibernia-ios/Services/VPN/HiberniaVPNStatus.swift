//
//  HiberniaVPNStatus.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 27/03/2025.
//

import Foundation

enum HiberniaVPNStatus: String {
    case requestingConfiguration = "Requesting Connection"
    case connecting = "Connecting"
    case connected = "Connected"
    case disconnecting = "Disconnecting"
    case disconnected = "Disconnected"
}
