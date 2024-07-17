//
//  RemoteConfigService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 17/07/2024.
//

import Foundation
import FirebaseRemoteConfig

@MainActor
class RemoteConfigService: ObservableObject {
    @Published var remoteConfiguration: RemoteConfiguration
    
    private var remoteConfig: RemoteConfig
    
    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.setDefaults(fromPlist: "rc_defaults")
        
        self.remoteConfiguration = try! remoteConfig.decoded(asType: RemoteConfiguration.self)
    }
    
    func fetch() async throws {
        try await remoteConfig.fetch()
    }
    
    func activate() async throws {
        try await remoteConfig.activate()
        try loadConfiguration()
    }
    
    func fetchAndActivate() async throws {
        try await remoteConfig.fetchAndActivate()
        try loadConfiguration()
    }
    
    func loadConfiguration() throws {
        self.remoteConfiguration = try! remoteConfig.decoded(asType: RemoteConfiguration.self)
    }
    
    struct RemoteConfiguration: Decodable {
        var destinations: [VPNService.VPNDestination]
        var locationSelectorCheckmarks: Bool
        var serviceMessage: String
        
        enum CodingKeys: String, CodingKey {
            case destinations = "destinations"
            case locationSelectorCheckmarks = "location_selector_checkmarks"
            case serviceMessage = "service_message"
        }
    }
}
