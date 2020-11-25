//
//  ExchangeRatesModel.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation
import Common

struct ExchangeRatesModel: Codable {

    let amount: Double
    let currency: Currency
    let items: [ExchangeRateModel]
    
}

// MARK: - Extensions

extension ExchangeRatesModel {
    
    var formattedAmount: String {
        "\(amount.goodDecimal())"
    }
    
}
