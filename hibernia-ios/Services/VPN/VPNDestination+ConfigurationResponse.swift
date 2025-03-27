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
    var id: String
    var type: VPNDestinationType
    var displayedName: String
}

enum VPNDestinationType: String, Codable {
    case classic
    case dedicated
}
