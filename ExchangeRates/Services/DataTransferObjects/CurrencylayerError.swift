//
//  CurrencylayerError.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation

struct CurrencylayerError: Codable, Error {
    let code: Int
    let info: String
}
