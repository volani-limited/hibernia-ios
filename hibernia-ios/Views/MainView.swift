//
//  ContentView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 26/09/2022.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MainView: View {
    @EnvironmentObject var subscriptionService: IAPSubscriptionService
    @EnvironmentObject var vpnService: VPNService

    @State private var isOpen = false
    @State private var serviceMessage: String?
    @State private var presentDetailsAlert = false
    @State var dragAmount = CGFloat(0)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Text("HiberniaVPN")
                        .font(.custom("Comfortaa", size: 30))
                        .foregroundStyle(LinearGradient(.highlightStart, .highlightEnd))
                        .onTapGesture {
                            presentDetailsAlert = true
                        }
                        .alert(isPresented: $presentDetailsAlert, content: { (subscriptionService.originalTransactionID != nil) ?
                                Alert(
                                    title: Text("Credits"),
                                    message: Text("Made with ❤️ in the South of England\nHibernia contains code licensed under the MPL, https://github.com/passepartoutvpn/tunnelkit\n\nV1.4.6 (40)\n\n Subscription ID: " + subscriptionService.originalTransactionID!.description),
                                    dismissButton: .cancel()
                                )
                            :
                                Alert(
                                    title: Text("Credits"),
                                    message: Text("Made with ❤️ in the South of England\nHibernia contains code licensed under the MPL, https://github.com/passepartoutvpn/tunnelkit\n\nV1.4.6 (40)"),
                                    dismissButton: .cancel()
                                )
                            })

                    Spacer().frame(height: geometry.size.height/10)
                    if subscriptionService.originalTransactionID == nil {
                        PurchaseSubscriptionButtonView()
                            .disabled(subscriptionService.subscriptionProduct == nil)
                    }
                    
                    if let serviceMessage = serviceMessage, !serviceMessage.isEmpty {
                        HStack(spacing: 10) {
                            VStack(spacing: 5) {
                                Text(serviceMessage)
                                    .font(.custom("Comfortaa", size: 13))
                                    .foregroundColor(.highlightStart)
                            }.padding()
                            Image(systemName: "xmark")
                                .padding()
                                .foregroundColor(.highlightEnd)
                        }
                        .background(
                            NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 10))
                        ).onTapGesture {
                            self.serviceMessage = nil
                        }
                    }
                    
                    ErrorDisplayView().padding(.top)
                    
                    VPNConnectButton().disabled(subscriptionService.originalTransactionID == nil)
                }.frame(width: geometry.size.width, height:geometry.size.height - 80)
                    .offset(y: -40)
                
                VStack {
                    CountrySelectorView()
                        .disabled(vpnService.status != .disconnected)
                    KeepAliveEnableButtonView()
                        .padding()
                        .offset(y: -130)
                }.frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: geometry.size.width)
                
                
                ViewSwitcherBarButtonView(isOpen: $isOpen, geometry: geometry)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 80)
            }
            .background(
                LinearGradient(Color.backgroundStart, Color.backgroundEnd)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geometry.size.width*2, height: geometry.size.height)
                    .offset(x: geometry.size.width/2))
            .offset(x: isOpen ? -geometry.size.width + dragAmount : dragAmount)
            .gesture(DragGesture().onChanged { value in
                if isOpen {
                    if value.translation.width.sign == .plus {
                        dragAmount = value.translation.width
                    }
                } else {
                    if value.translation.width.sign == .minus {
                        dragAmount = value.translation.width
                    }
                }
            }.onEnded { value in
                dragAmount = 0
                if abs(value.predictedEndTranslation.width) > (geometry.size.width - 60) {
                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    feedbackGenerator.impactOccurred()

                    if value.translation.width.sign == .plus {
                        isOpen = false
                    } else {
                        isOpen = true
                    }
                }
               
            })
        }
        .onAppear {
            let db = Firestore.firestore()
            let ref = db.collection("config").document("serviceMessage")
            
            ref.getDocument() { (document, error) in
               if let document = document, document.exists {
                   self.serviceMessage = document.get("message") as? String
               }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
