//
//  RatesDTO.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation

struct RatesDTO: Codable {
    let source: String
    let quotes: [String: Double]
}
