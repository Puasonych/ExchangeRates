//
//  CurrencylayerResponse.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation

struct CurrencylayerResponse<Body: Codable>: Codable {
    
    enum CodingKeys: String, CodingKey {
        case success
        case terms
        case privacy
    }
    
    let success: Bool
    let terms: String?
    let privacy: String?
    let data: Body
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        self.terms = try container.decodeIfPresent(String.self, forKey: .terms)
        self.privacy = try container.decodeIfPresent(String.self, forKey: .privacy)
        
        if success {
            self.data = try Body(from: decoder)
        } else {
            throw try CurrencylayerError(from: decoder)
        }
    }
}
