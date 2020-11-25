//
//  CurrenciesModel.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation
import Common

struct CurrenciesModel: Codable {

    let timestamp: Date
    let currencies: [Currency: String]
    
}

extension CurrencylayerResponse where Body == CurrenciesDTO {
    
    var toCurrenciesModel: CurrenciesModel {
        let currencies: [Currency: String] = data.currencies.reduce([:]) { $0 + [Currency($1.key): $1.value] }
        return CurrenciesModel(
            timestamp: Date(),
            currencies: currencies
        )
    }
    
}
