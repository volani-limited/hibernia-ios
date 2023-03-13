//
//  VPNService.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 01/10/2022.
//

import Foundation
import Combine

import TunnelKitCore
import TunnelKitManager
import TunnelKitOpenVPN

import NetworkExtension

import FirebaseAppCheck

class VPNService: ObservableObject {
    static let tunnelIdentifier = "uk.co.volani.hibernia-ios.OpenVPNTunnel"
    static let appGroup = "group.uk.co.volani.hibernia-ios"
    
    @Published var status: VPNStatus
    @Published var destination: VPNDestination
    @Published var vpnServiceError: Error?
    @Published var retryHandler: (() -> Void)?
    
    @Published var keepAlive: Bool
    @Published var killSwitch: Bool
    @Published var connectedTime: String
    
    var timer: SimpleTimerService
    
    private var configuration: OpenVPN.Configuration?
    private var subscriptions: Set<AnyCancellable>
    private var vpn: NetworkExtensionVPN

    init() {
        vpn = NetworkExtensionVPN()
        status = .disconnected
        timer = SimpleTimerService()
        connectedTime = "--:--"

        let defaults = UserDefaults.standard
        destination = VPNDestination(rawValue: defaults.string(forKey: "destination") ?? "lon") ?? .lon
        
        keepAlive = defaults.bool(forKey: "keepAlive")
        killSwitch = defaults.bool(forKey: "keepAlive")
        
        subscriptions = Set<AnyCancellable>()
        
        subscriptions.insert($destination.sink { value in
            defaults.set(value.rawValue, forKey: "destination")
        })
        subscriptions.insert($keepAlive.sink { value in
            defaults.set(value, forKey: "keepAlive")
        })
        subscriptions.insert($killSwitch.sink { value in
            defaults.set(value, forKey: "killSwitch")
        })
        
        timer.$elapsedTime.map {
            let formatter = DateComponentsFormatter() //Use dateFormatter to convert date interval into minutes and seconds
            
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad
            formatter.unitsStyle = .positional
            
            
            if let output = formatter.string(from: $0) {
                return output // return this value
            } else {
                return  "--:--" // if formatter fails return blank value
            }
        }.assign(to: &$connectedTime)
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNStatusDidChange(notification:)),
            name: VPNNotification.didChangeStatus,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNDidFail(notification:)),
            name: VPNNotification.didFail,
            object: nil
        )
    }
    
    deinit {
        subscriptions.map({ $0.cancel() })
    }

    func prepare() async {
        await vpn.prepare()
    }
    
    @MainActor
    func connect(transactionID: UInt64) async {
        do {
            self.configuration = try await self.requestConfiguration(destination: self.destination, transactionID: transactionID)
            
            let providerConfiguration = OpenVPN.ProviderConfiguration("HiberniaVPN", appGroup: VPNService.appGroup, configuration: self.configuration!)
           
            var configurationExtras = NetworkExtensionExtra()
            
            configurationExtras.disconnectsOnSleep = false
            
            if keepAlive {
                configurationExtras.onDemandRules = [NEOnDemandRuleConnect()]
            }
            
            try await vpn.reconnect(VPNService.tunnelIdentifier, configuration: providerConfiguration, extra: configurationExtras, after: .seconds(1))
            
            self.vpnServiceError = nil
            self.retryHandler = nil
        } catch {
            if let urlError = error as? URLError, urlError.code == URLError.Code.cancelled {
                return
            }

            self.vpnServiceError = error
            self.status = .disconnected
        }
    }
    
    func disconnect() {
        Task {
            await vpn.disconnect()
        }
    }
    
    func requestConfiguration(destination: VPNDestination, transactionID: UInt64) async throws -> OpenVPN.Configuration {
        let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false)
        
        let url = URL(string: "https://provision-configuration-1-xgpoqrynja-lm.a.run.app?app_token=\(appCheckToken.token)&subscription_id=\(transactionID)&location=\(destination.rawValue)")

        let request = URLRequest(url: url!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpsResponse = response as? HTTPURLResponse else {
            throw VPNError.configurationRequestError
        }
        
        if  httpsResponse.statusCode == 200 {
            let decodedData = try JSONDecoder().decode(ConfigurationResponse.self, from: data)
            let parser = try OpenVPN.ConfigurationParser.parsed(fromContents: decodedData.configuration)
            
            return parser.configuration
        } else if httpsResponse.statusCode == 402 {
            throw VPNError.subscriptionPaymentError
        } else {
            throw VPNError.configurationRequestError
        }
    }
    
    @objc private func VPNStatusDidChange(notification: Notification) {
        status = notification.vpnStatus
        print("VPNStatusDidChange: \(status)")
        
        if status == .connected {
            timer.reset()
            timer.start()
        } else if status == .disconnecting {
            timer.stop()
        }
    }

    @objc private func VPNDidFail(notification: Notification) {
        print("VPNStatusDidFail: \(notification.vpnError.localizedDescription)")
    }
}

struct ConfigurationResponse: Codable {
    let response: String
    let configuration: String
}

enum VPNDestination: String , CaseIterable {
    case lon
    case sgy
    case nyc
    case tor
    case tyo
    case syd
    case dal
    case fra
    case fre
    case mum
    
    var displayed: String {
        switch self {
        case .lon:
            return "London 🇬🇧"
        case .sgy:
            return "Singapore 🇸🇬"
        case .nyc:
            return "New York 🇺🇸"
        case .tyo:
            return "Tokyo 🇯🇵"
        case .syd:
            return "Sydney 🇦🇺"
        case .dal:
            return "Dallas 🇺🇸"
        case .fra:
            return "Frankfurt 🇩🇪"
        case .mum:
            return "Mumbai 🇮🇳"
        }
    }
}


enum VPNError: LocalizedError {
    case configurationRequestError
    case subscriptionPaymentError
    
    public var errorDescription: String? {
        switch self {
        case .configurationRequestError:
            return "Configuration request failed."
        case .subscriptionPaymentError:
            return "Subscription could not be verified."
        }
    }
}
