//
//  CountrySelectorButtonView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 04/10/2022.
//

import SwiftUI

struct CountrySelectorButtonView: View {
    @Binding var isOpen: Bool
    var geometry: GeometryProxy
    var body: some View {
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
                    //Spacer()
                    Text("London").foregroundColor(.black)//.offset(x: isOpen ? -30 : 30)
                    Spacer().frame(width: isOpen ? 25 : geometry.size.width/3)
                    Image(systemName: isOpen ? "chevron.compact.left" : "chevron.compact.right")//.offset(x: isOpen ? 5 : geometry.size.width/1.5)
                    
                }.padding().frame(width: geometry.size.width)
            }.offset(x: geometry.size.width / 2)
        }
    }
}

struct CountrySelectorButtonView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            CountrySelectorButtonView(isOpen: .constant(false), geometry: geometry).position(x: geometry.size.width / 2, y: geometry.size.height - 80).scaleEffect(0.3)
        }
        
    }
}

