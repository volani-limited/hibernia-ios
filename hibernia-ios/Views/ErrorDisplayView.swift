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
                
                        authService.authServiceError = nil
                    }
                } label: {
                    HStack {
                        Text(authError.localizedDescription)
                            .font(.custom("Comfortaa", size: 20))
                            .foregroundColor(.red)
                            .padding()
                            .background(
                                NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 5))
                            )
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            
            if let subsciptionError = subscriptionService.iapSubscriptionServiceError {
                Button {
                    Task {
                        if let retry = subscriptionService.retryHandler {
                            await retry()
                        }
                        subscriptionService.iapSubscriptionServiceError = nil
                    }
                } label: {
                    HStack {
                        Text(subsciptionError.localizedDescription)
                            .font(.custom("Comfortaa", size: 20))
                            .foregroundColor(.red)
                            .padding()
                            .background(
                                NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 5))
                            )
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            
            if let vpnError = vpnService.vpnServiceError {
                Button {
                    Task {
                        if let retry = vpnService.retryHandler {
                            await retry()
                        }
                        vpnService.vpnServiceError = nil
                    }
                } label: {
                    Text(vpnError.localizedDescription)
                        .font(.custom("Comfortaa", size: 20))
                        .foregroundColor(.red)
                        .padding()
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
