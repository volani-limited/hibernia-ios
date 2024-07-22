//
//  ServiceMessageView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 22/07/2024.
//

import SwiftUI
import FirebaseRemoteConfig

struct ServiceMessageView: View {
    @RemoteConfigProperty(key: "serviceMessage", fallback: "") var serviceMessage: String
    
    @State var dismissed: Bool = false
    
    var body: some View {
        if !serviceMessage.isEmpty {
            HStack {
                Text(.init(serviceMessage))
                    .font(.custom("Comfortaa", size: 17))
                    .foregroundStyle(Color.titleText)
                    .bold()
                
                Button {
                    dismissed = true
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.turquoise)
                }
            }
            .padding()
            .background(NeumorphicShape(isHighlighted: true, shape: RoundedRectangle(cornerRadius: 25)))
            .opacity(dismissed ? 0 : 1)
            .disabled(dismissed)
        }
    }
}
