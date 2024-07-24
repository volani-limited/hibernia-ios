//
//  FirebaseRemoteConfigService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/10/2023.
//

import Foundation
import Firebase

class FirebaseRemoteConfigService: ObservableObject {
    @Published var remoteConfig: RemoteConfig
    
    init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        
        remoteConfig.configSettings = settings
    }
    
    public func fetchAndActivate() async throws {
        try await remoteConfig.fetchAndActivate()
    }
}
