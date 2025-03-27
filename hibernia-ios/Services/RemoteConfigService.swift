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
        remoteConfigManager.configSettings = settings
        
        remoteConfigManager.setDefaults(fromPlist: "rc_defaults")

        self.remoteConfiguration = try! remoteConfigManager.decoded(asType: RemoteConfiguration.self)
    }
    
    private static func decodeConfig(remoteConfig: RemoteConfig) -> RemoteConfiguration {
        let destinationSelectorCheckmarks = remoteConfig.configValue(forKey: "destinationSelectorCheckmarks").boolValue
        let serviceMessage = remoteConfig.configValue(forKey: "serviceMessage").stringValue!
        
        let destinationsString = remoteConfig.configValue(forKey: "destinations").stringValue!
        let destinationsJson = destinationsString.data(using: .utf8)!
        
        let destinations = try! JSONDecoder().decode([VPNDestination].self, from: destinationsJson)
        
        return RemoteConfiguration(destinations: destinations, destinationSelectorCheckmarks: destinationSelectorCheckmarks, serviceMessage: serviceMessage)
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
        var destinations: [VPNDestination]
        var destinationSelectorCheckmarks: Bool
        var serviceMessage: String
    }
}
