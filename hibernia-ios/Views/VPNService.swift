//
//  VPNService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 01/10/2022.
//

import Foundation

class VPNService: ObservableObject {
    @Published var connected: Bool
    @Published var connecting: Bool
    
    init() {
        connected = false
        connecting = false
    }
}
