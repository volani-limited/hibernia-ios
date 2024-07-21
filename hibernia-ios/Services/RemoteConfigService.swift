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
    
    private var remoteConfigManager: RemoteConfig
    
    init() {
        remoteConfigManager = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfigManager.configSettings = settings
        
        remoteConfigManager.setDefaults(fromPlist: "rc_defaults")
        
        self.remoteConfiguration = try! remoteConfigManager.decoded(asType: RemoteConfiguration.self)
    }
    
    func fetch() async throws {
        try await remoteConfigManager.fetch()
    }
    
    func activate() async throws {
        try await remoteConfigManager.activate()
        self.remoteConfiguration = try! remoteConfigManager.decoded(asType: RemoteConfiguration.self)
    }
    
    func fetchAndActivate() async throws {
        try await remoteConfigManager.fetchAndActivate()
        self.remoteConfiguration = try! remoteConfigManager.decoded(asType: RemoteConfiguration.self)
    }
    
    struct RemoteConfiguration: Decodable {
        var destinations: [VPNService.VPNDestination]
        var locationSelectorCheckmarks: Bool
        var serviceMessage: String
    }
}
