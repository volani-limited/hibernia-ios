//
//  WireguardVPNConfiguration.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 27/03/2025.
//

struct WireguardVPNConfiguration: Codable {
    var privateKey: String?
    var keepAlive: Bool?

    let address: String
    let dns: String
    
    let publicKey: String
    let allowedIPs: String
    let endpoint: String
    
    enum CodingKeys: String, CodingKey {
        case address
        case dns
        case publicKey = "public_key"
        case privateKey = "private_key"
        case allowedIPs = "allowed_ips"
        case endpoint
        case keepAlive = "keep_alive"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.address = try container.decode(String.self, forKey: .address)
        self.dns = try container.decode(String.self, forKey: .dns)
        self.publicKey = try container.decode(String.self, forKey: .publicKey)
        self.allowedIPs = try container.decode(String.self, forKey: .allowedIPs)
        self.endpoint = try container.decode(String.self, forKey: .endpoint)
        
        self.privateKey = try? container.decode(String.self, forKey: .privateKey)
        self.keepAlive = try? container.decode(Bool.self, forKey: .keepAlive)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(address, forKey: .address)
        try container.encode(dns, forKey: .dns)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encode(allowedIPs, forKey: .allowedIPs)
        try container.encode(endpoint, forKey: .endpoint)
        
        try container.encodeIfPresent(privateKey, forKey: CodingKeys.privateKey)
        try container.encodeIfPresent(keepAlive, forKey: CodingKeys.keepAlive)
    }
}
