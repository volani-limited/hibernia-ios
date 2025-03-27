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
    
    init(privateKey: String?, keepAlive: Bool?, address: String, dns: String, publicKey: String, endpoint: String) {
        self.privateKey = privateKey
        self.keepAlive = keepAlive
        self.address = address
        self.dns = dns
        self.publicKey = publicKey
        self.endpoint = endpoint
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.address = try container.decode(String.self, forKey: .address)
        self.dns = try container.decode(String.self, forKey: .dns)
        self.publicKey = try container.decode(String.self, forKey: .publicKey)
        self.endpoint = try container.decode(String.self, forKey: .endpoint)
        
        self.privateKey = try? container.decode(String.self, forKey: .privateKey)
        self.keepAlive = try? container.decode(Bool.self, forKey: .keepAlive)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(address, forKey: .address)
        try container.encode(dns, forKey: .dns)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encode(endpoint, forKey: .endpoint)
        
        try container.encodeIfPresent(privateKey, forKey: CodingKeys.privateKey)
        try container.encodeIfPresent(keepAlive, forKey: CodingKeys.keepAlive)
    }
}
