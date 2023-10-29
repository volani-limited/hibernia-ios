//
//  DeviceCheckAppCheckProviderFactory.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 18/11/2022.
//

import Foundation

import Foundation
import Firebase
import FirebaseAppCheck

class DeviceCheckAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return DeviceCheckProvider(app: app)
  }
}
