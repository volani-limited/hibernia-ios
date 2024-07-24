//
//  SettingsExtraSettingsCardView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 23/07/2024.
//

import SwiftUI

struct SettingsExtraSettingsCardView: View {
    @EnvironmentObject var settingsService: UserSettingsService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("USER SETTINGS")
                .font(.caption)
                .foregroundColor(.text)
                .padding(.bottom, 2)
            
            HStack {
                Text("Appearance")
                    .font(.custom("Comfortaa", size: 22))
                    .foregroundStyle(Color.text)
                
                Spacer()
                
                Menu {
                    Picker("", selection: $settingsService.preferredAppAppearance) {
                        ForEach(UserSettingsService.PreferredAppAppearance.allCases, id: \.self) { option in
                            Text(option.displayed)
                        }
                    }
                } label: {
                    HStack (alignment: .center) {
                        Text(settingsService.preferredAppAppearance.displayed)
                            .font(.custom("Comfortaa", size: 18))
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .foregroundStyle(Color.turquoise)
                }
            }
        }
        .padding()
        .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)))
    }
}
