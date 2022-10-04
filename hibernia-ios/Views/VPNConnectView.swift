//
//  VPNConnectview.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

struct VPNConnectView: View {
    @State private var isToggled = false
    
    var body: some View {
        GeometryReader { geometry in
            //if let errorDescription = authService.authServiceError?.localizedDescription {
            VStack {
                Text("HiberniaVPN")
                Spacer()
                Spacer()
                Toggle(isOn: $isToggled) {
                    Image(systemName: "power")
                        .font(.system(size: 45, weight: .heavy))
                        .foregroundColor(.highlightStart)
                    //.shadow(color: Color.highlightEnd, radius: 4)
                }.disabled(false)
                    .toggleStyle(MainButtonToggleStyle())
                
                Spacer()
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
}

struct VPNConnectView_Previews: PreviewProvider {
    @State var isOpen = false
    static var previews: some View {
        VPNConnectView().scaleEffect(1)
    }
}

