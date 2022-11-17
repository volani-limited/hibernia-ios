//
//  CountrySelectorButtonView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 04/10/2022.
//

import SwiftUI

struct ViewSwitcherBarButtonView: View {
    @EnvironmentObject var vpnService: VPNService
    @Environment(\.colorScheme) var colorScheme

    @Binding var isOpen: Bool

    var geometry: GeometryProxy

    var body: some View {
        ZStack(alignment: isOpen ? .trailing : .leading) {
            NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 8))
                .frame(width: geometry.size.width * 2 - 50, height: 80)
           
            HStack {
                Spacer().frame(maxWidth: isOpen ? .infinity : 20)
                
                Text(vpnService.destination.displayed)
                    .foregroundColor(colorScheme == .dark ? .highlightStart : .highlightEnd)
                    .font(.custom("Comfortaa", size: 20))
                
                Spacer().frame(maxWidth: isOpen ? 5 : .infinity)
                
                Image(systemName: isOpen ? "chevron.backward" : "chevron.forward")
                    .foregroundColor(.highlightEnd)
            }
            .padding()
            .frame(width: geometry.size.width - 50)
            .animation(.linear, value: isOpen)
        }.offset(x: geometry.size.width / 2)
            .onTapGesture {
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                feedbackGenerator.impactOccurred()
                withAnimation {
                    isOpen.toggle()
                }
        }
    }
}

struct CountrySelectorButtonView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ViewSwitcherBarButtonView(isOpen: .constant(false), geometry: geometry).position(x: geometry.size.width / 2, y: geometry.size.height - 80).scaleEffect(1)
        }
        
    }
}

