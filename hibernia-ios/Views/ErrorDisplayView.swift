//
//  ErrorDisplayView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 06/10/2022.
//

import SwiftUI

struct ErrorDisplayView: View {
    @EnvironmentObject var subscriptionService: IAPSubscriptionService
    @EnvironmentObject var vpnService: VPNService
    
    var body: some View { // Present error and attach retry handler for retry button
        VStack {
            if let subsciptionError = subscriptionService.iapSubscriptionServiceError {
                Button {
                    Task {
                        if let retry = subscriptionService.retryHandler {
                            await retry()
                        }
                    }
                    
                    subscriptionService.iapSubscriptionServiceError = nil
                    subscriptionService.retryHandler = nil
                } label: {
                    HStack(spacing: 10) {
                        VStack(spacing: 5) {
                            Text("Error processing subscription")
                                .font(.custom("Comfortaa", size: 14))
                                .foregroundColor(.red)
                                
                            Text(subsciptionError.localizedDescription)
                                .font(.custom("Comfortaa", size: 8))
                                .foregroundColor(.red)
                        }.padding()

                        Image(systemName: "arrow.clockwise")
                            .padding()
                            .foregroundColor(.highlightStart)
                    }
                    .background(
                        NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 10))
                    )
                }
            }
            
            if let vpnError = vpnService.vpnServiceError {
                Button {
                    Task {
                        await subscriptionService.updateSubscriptionStatus()
                    }
                    
                    if let retry = vpnService.retryHandler {
                         retry()
                    }
                    
                    vpnService.vpnServiceError = nil
                    vpnService.retryHandler = nil
                } label: {
                    HStack(spacing: 10) {
                        VStack(spacing: 5) {
                            Text("Error connecting to VPN")
                                .font(.custom("Comfortaa", size: 14))
                                .foregroundColor(.red)
                                
                            Text(vpnError.localizedDescription)
                                .font(.custom("Comfortaa", size: 8))
                                .foregroundColor(.red)
                        }.padding()

                        Image(systemName: "arrow.clockwise")
                            .padding()
                            .foregroundColor(.highlightStart)
                    }
                    .background(
                        NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 10))
                    )
                }
            }
        }
    }
}

struct ErrorDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorDisplayView()
    }
}
