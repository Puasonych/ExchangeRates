//
//  ExchangeRatesService.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation
import RService
import Combine

struct ExchangeRatesService: HTTPServiceProtocol {
    
    // MARK: - Nested types
    
    enum Constants {
        static let baseUrl = URL(string: "http://api.currencylayer.com")!
        static let accessKey = "fbc881ec6b13b65704f870a9285b2e8d"
    }
    
    @GET(Constants.baseUrl, "/list?access_key=\(Constants.accessKey)")
    var loadCurrencies: JustRequest<CurrencylayerResponse<CurrenciesDTO>>
    
    @GET(Constants.baseUrl, "/live?access_key=\(Constants.accessKey)")
    var loadDefaultRates: JustRequest<CurrencylayerResponse<RatesDTO>>
    
}
