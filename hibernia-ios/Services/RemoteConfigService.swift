//
//  RemoteConfigService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 21/03/2023.
//

import Foundation
import Firebase

class RemoteConfigService: ObservableObject {
    @Published var remoteConfig: RemoteConfig
    
    init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        
        remoteConfig.configSettings = settings
        
        remoteConfig.setDefaults(fromPlist: "rcdefaults")
        
    }
}
