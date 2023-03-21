//
//  AttestationService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 12/11/2022.
//

import Foundation
import Firebase
import FirebaseAppCheck

class AppAttestAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return AppAttestProvider(app: app)
  }
}
