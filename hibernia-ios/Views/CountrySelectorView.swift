//
//  CountrySelectorView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

struct CountrySelectorView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                //RoundedRectangle(cornerRadius: 25).foregroundColor(.backgroundEnd).frame(width: geometry.size.width + 50).edgesIgnoringSafeArea(.all)
                //if let errorDescription = authService.authServiceError?.localizedDescription {
                VStack {
                    Text("France")
                    Text("Germany")
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct CountrySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CountrySelectorView()
    }
}
