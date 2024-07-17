//
//  AcknowledgementsView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 11/06/2024.
//

import SwiftUI

struct AcknowledgementsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.text)
                            .padding()
                    }
                    .buttonStyle(NeumorphicButtonStyle(shape: Circle()))
                    .padding()
                    
                    Spacer()
                }
                
                
                Text("HiberniaVPN makes use of the following open-source libraries.")
                    .bold()
                    .font(.title)
                    .foregroundColor(.titleText)
                    .padding(.leading)
                // TODO: finish addling acknolwedgments
                Spacer()
            }
        }
    }
}

#Preview {
    AcknowledgementsView()
}
