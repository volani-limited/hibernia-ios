//
//  AcknowledgementsView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 11/06/2024.
//

import SwiftUI

struct AcknowledgementsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var acknowledgements = [
        Acknowledgement(title: "HiberniaVPN Client", copyright: "© Volani Limited MMXXIV.", licensed: "Source code provided under the GPLv3.", licenseLink: URL(string: "https://www.gnu.org/licenses/gpl-3.0.en.html")!, sourceCodeLink: URL(string: "https://github.com/volani-limited/hibernia-ios")!),
        Acknowledgement(title: "TunnelKit", copyright: "© Davide De Rosa. All rights reserved.", licensed: "Licensed under the MPLv2.", licenseLink: URL(string: "https://www.mozilla.org/en-US/MPL/2.0/")!, sourceCodeLink: URL(string: "https://github.com/volani-limited/tunnelkit")!),
        Acknowledgement(title: "OpenSSL", copyright: "© The Open SSL Project. All rights reserved.", licensed: "Licensed under the Apache License 2.0. OpenVPN is a registered trademark of OpenVPN, Inc.", licenseLink: URL(string: "https://www.apache.org/licenses/LICENSE-2.0")!, sourceCodeLink: URL(string: "https://github.com/openssl/openssl")!)]
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                ZStack {
                    Text("Acknowledgments")
                        .fontWeight(.black)
                        .font(.custom("Comfortaa", size: 22))
                        .foregroundStyle(Color.titleText)
                        .padding()
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
                }
                
                Text("HiberniaVPN may make use of and/or include the following open-source code")
                    .font(.custom("Comfortaa", size: 15))
                    .foregroundStyle(Color.text)
                    .padding(.horizontal)
                
                
                ScrollView {
                    VStack(spacing: 15) {
                        Spacer()
                        ForEach(acknowledgements, id: \.title) { acknowledgement in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(acknowledgement.title)
                                    .bold()
                                    .font(.custom("Comfortaa", size: 20))
                                    .foregroundStyle(Color.text)
                                Text(acknowledgement.copyright)
                                    .bold()
                                    .font(.custom("Comfortaa", size: 12))
                                    .foregroundStyle(Color.text)
                                Text(acknowledgement.licensed)
                                    .bold()
                                    .font(.custom("Comfortaa", size: 14))
                                    .foregroundStyle(Color.text)
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        openURL(acknowledgement.licenseLink)
                                    } label: {
                                        Text("License")
                                        Image(systemName: "arrow.up.right.square.fill")
                                    }
                                    
                                    Text("•")

                                    Button {
                                        openURL(acknowledgement.sourceCodeLink)
                                    } label: {
                                        Text("Source")
                                        Image(systemName: "arrow.up.right.square.fill")
                                    }
                                    
                                    Spacer()
                                }
                                .font(.system(size: 15))
                                .foregroundStyle(Color.turquoise)
                            }
                        }
                        .padding()
                        .background(NeumorphicShape(shape: RoundedRectangle(cornerRadius: 25)))
                    }
                    .padding()
                }
            }
        }
    }
    struct Acknowledgement {
        var title: String
        var copyright: String
        var licensed: String
        var licenseLink: URL
        var sourceCodeLink: URL
    }
}
