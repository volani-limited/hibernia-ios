//
//  LocationSelectorRowView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 08/03/2024.
//

import SwiftUI

struct LocationSelectorRowView: View {
    var location: VPNDestination

    var body: some View {
        Text(location.displayed)
            .font(.custom("Comfortaa", size: 20))
            .padding()
    }
}

#Preview {
    LocationSelectorRowView()
}
