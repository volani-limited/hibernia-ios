//
//  VPNConnectview.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

struct VPNConnectView: View {
    @State private var isToggled = false
    @Binding var isOpen: Bool
    
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
                Button {
                    withAnimation {
                        isOpen.toggle()
                    }
                } label:{
                    ZStack(alignment: isOpen ? .trailing : .leading) {
                        RoundedRectangle(cornerRadius: 5).foregroundColor(.backgroundEnd)
                        //.blendMode(.destinationOut)
                            .frame(width: geometry.size.width * 2 - 50, height: 80)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                        //.background(NeumorphicBackground(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 5)))
                       
                        HStack {
                            Text("London").foregroundColor(.black).offset(x: isOpen ? -30 : 30)
                            
                            Image(systemName: isOpen ? "chevron.compact.left" : "chevron.compact.right").offset(x: isOpen ? 10 : geometry.size.width/1.5)
                            //Spacer()
                        }.padding()
                    }.offset(x: geometry.size.width / 2)
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
}

struct VPNConnectView_Previews: PreviewProvider {
    @State var isOpen = false
    static var previews: some View {
        VPNConnectView(isOpen: .constant(true)).scaleEffect(1)
    }
}

