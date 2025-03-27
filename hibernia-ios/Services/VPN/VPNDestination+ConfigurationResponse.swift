//
//  VPNDestination.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 27/03/2025.
//

struct ConfigurationRepsonse: Codable {
    let response: String
    let configuration: String
}

struct VPNDestination: Identifiable, Hashable, Codable {
    enum VPNDestinationType: String, Codable {
        case classic
        case dedicated
    }

    var id: String
    var displayedName: String
    var type: VPNDestinationType
}
