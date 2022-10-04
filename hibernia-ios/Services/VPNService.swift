//
//  VPNService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 01/10/2022.
//

import Foundation

class VPNService: ObservableObject {
    @Published var connected: Bool
    @Published var connecting: Bool
    @Published var destination: VPNDestination
    
    init() {
        connected = false
        connecting = false
        destination = .london
    }
}

enum VPNDestination: String , CaseIterable {
    case london = "London 🇬🇧"
    case singapore = "Singapore 🇸🇬"
    case newyork = "New York 🇺🇸"

}
