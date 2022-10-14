//
//  ErrorDisplayView.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 06/10/2022.
//

import SwiftUI

struct ErrorDisplayView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var subscriptionService: IAPSubscriptionService
    @EnvironmentObject var vpnService: VPNService
    
    var body: some View {
        VStack {
            if let authError = authService.authServiceError {
                Button {
                    if let retry = authService.retryHandler {
                        retry()
                    }
                    
                    authService.authServiceError = nil
                    authService.retryHandler = nil
                } label: {
                    HStack(spacing: 10) {
                        VStack(spacing: 5) {
                            Text("Error authenticating device")
                                .font(.custom("Comfortaa", size: 15))
                                .foregroundColor(.red)
                            Text(authError.localizedDescription)
                                .font(.custom("Comfortaa", size: 9))
                                .foregroundColor(.red)
                                
                        }.padding()
                        Image(systemName: "arrow.clockwise")
                            .padding()
                            .foregroundColor(.highlightStart)
                    }
                    .background(
                        NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 5))
                    )
                }
            }
            
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
                                .font(.custom("Comfortaa", size: 15))
                                .foregroundColor(.red)
                                
                            Text(subsciptionError.localizedDescription)
                                .font(.custom("Comfortaa", size: 9))
                                .foregroundColor(.red)
                        }.padding()
                        Image(systemName: "arrow.clockwise")
                            .padding()
                            .foregroundColor(.highlightStart)
                    }
                    .background(
                        NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 5))
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
                                .font(.custom("Comfortaa", size: 15))
                                .foregroundColor(.red)
                                
                            Text(vpnError.localizedDescription)
                                .font(.custom("Comfortaa", size: 9))
                                .foregroundColor(.red)
                        }.padding()
                        Image(systemName: "arrow.clockwise")
                            .padding()
                            .foregroundColor(.highlightStart)
                    }
                    .background(
                        NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 5))
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
