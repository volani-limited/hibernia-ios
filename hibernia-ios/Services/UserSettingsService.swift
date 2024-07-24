//
//  UserPreferencesService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 23/07/2024.
//

import Foundation
import Combine
import UIKit
import SwiftUI

@MainActor
class UserSettingsService: ObservableObject {
    @Published var preferredAppAppearance: PreferredAppAppearance
    
    private var subscriptions: Set<AnyCancellable>
    
    init() {
        subscriptions = Set<AnyCancellable>()
        
        let defaults = UserDefaults.standard // Load data from userdefaults
        preferredAppAppearance = PreferredAppAppearance(rawValue: defaults.string(forKey: "preferredAppAppearance") ?? "matchSystem") ?? .matchSystem
        
        $preferredAppAppearance.sink { [weak self] value in
            self?.recievePreferredAppearanceUpdate(value: value)
        }.store(in: &subscriptions)
    }
    
    deinit {
        subscriptions.map { $0.cancel() }
    }
    
    private func recievePreferredAppearanceUpdate(value: PreferredAppAppearance) {
        let defaults = UserDefaults.standard
        defaults.set(value.rawValue, forKey: "preferredAppAppearance")
        
        if #unavailable(iOS 18) {
            if value == .dark {
                UIApplication.shared.setAlternateIconName("AppIcon-Dark")
            } else {
                UIApplication.shared.setAlternateIconName(nil)
            }
        }
    }
        
    enum PreferredAppAppearance: String, CaseIterable {
        case light
        case dark
        case matchSystem
        
        var displayed: String {
            switch self {
            case .light:
                "Light"
            case .dark:
                "Dark"
            case .matchSystem:
                "Match system"
            }
        }
        
        var colorSchemeEquivalent: ColorScheme? {
            switch self {
            case .light:
                return .light
            case .dark:
                return .dark
            case .matchSystem:
                return nil
            }
        }
    }
}
