//
//  VPNConnectview.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

struct VPNConnectButton: View {
    @State private var isToggled = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Toggle(isOn: $isToggled) {
                    Image(systemName: "power")
                        .font(.system(size: 45, weight: .heavy))
                        .foregroundColor(.highlightStart)
                    //.shadow(color: Color.highlightEnd, radius: 4)
                }.disabled(false)
                    .toggleStyle(MainButtonToggleStyle())
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
}

struct VPNConnectView_Previews: PreviewProvider {
    @State var isOpen = false
    static var previews: some View {
        VPNConnectButton().scaleEffect(1)
    }
}

