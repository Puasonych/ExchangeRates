//
//  RatesModel.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation
import Common

struct RatesModel: Codable {

    let timestamp: Date
    let sourceCurrency: Currency
    let quotes: [Currency: Double]
    let terms: String?
    let privacy: String?
    
}

extension CurrencylayerResponse where Body == RatesDTO {
    
    var toRatesModel: RatesModel {
        RatesModel(
            timestamp: Date(),
            sourceCurrency: Currency(data.source),
            quotes: data.quotes.reduce([:]) { $0 + [Currency(String($1.key.suffix(3))): $1.value] },
            terms: terms,
            privacy: privacy
        )
    }
    
}
