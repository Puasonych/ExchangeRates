//
//  ExchangeRateModel.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation
import Common

struct ExchangeRateModel: Codable, Identifiable {
    
    let id: UUID
    let amount: Double
    let currency: Currency
    let quote: Double
    
}

// MARK: - Extensions

extension ExchangeRateModel {
    
    var formattedAmount: String {
       "\(amount.goodDecimal())"
    }
    
    var formattedQuota: String {
        "\(quote.goodDecimal())"
    }
    
    var copyText: String {
        "\(currency.isoCode) \(formattedAmount)"
    }
    
}
