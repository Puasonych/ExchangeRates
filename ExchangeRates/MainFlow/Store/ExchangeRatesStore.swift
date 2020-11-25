//
//  ExchangeRatesStore.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation
import Common
import Combine

final class ExchangeRatesStore: ObservableObject, CurrencyListOutputProtocol {
    
    // MARK: - Nested types
    
    enum Constants {
        static let validDataTimeinterval: TimeInterval = 30 * 60
    }
    
    enum RatesState {
        case emptyContent
        case content(ExchangeRatesModel)
        case loading
        case error(String)
    }
    
    // MARK: - Substores
    
    private(set) var currencyStore = CurrencyListStore()
    
    // MARK: - Properties
    
    private(set) var amount: Double = defaults.amount
    private(set) var terms = URL(string: "https://currencylayer.com/terms")!
    private(set) var privacyPolicy = URL(string: "https://currencylayer.com/privacy")!
    @Published private(set) var currency: Currency = defaults.currency ?? .default
    @Published private(set) var ratesState: RatesState = .emptyContent
    
    // MARK: - Private properties
    
    private static var defaults = UserDefaults.exchangeRatesStore
    private lazy var service = ExchangeRatesService()
    private var loadingProcess: AnyCancellable?
    
    // MARK: - Computed properties
    
    private var currentValidModel: RatesModel? {
        guard let model = Self.defaults.rates, !model.quotes.isEmpty else {
            return nil
        }
        let currentDate = Date()
        return (model.timestamp < currentDate && model.timestamp.distance(to: currentDate) > Constants.validDataTimeinterval)
            ? nil
            : model
    }
    
    // MARK: - Initializers
    
    init() {
        currencyStore.configure(currency: currency)
        currencyStore.configure(output: self)
    }
    
    // MARK: - Methods
    
    func prepare() {
        guard let model = Self.defaults.exchangeRates else { return }
        self.ratesState = .content(model)
    }
    
    func set(amount: String) {
        self.amount = amount.toDouble
        Self.defaults.amount = self.amount
    }
    
    func set(currency: Currency) {
        self.currency = currency
        currencyStore.configure(currency: currency)
        Self.defaults.currency = currency
    }
    
    func loadRates() {
        getExchangeRates(amount: amount, currency: currency) { [unowned self] result in
            switch result {
            case let .success(model):
                self.ratesState = .content(model)
            case let .failure(error):
                switch error {
                case let error as CurrencylayerError:
                    self.ratesState = .error(error.info)
                default:
                    self.ratesState = .error(ServiceError.unknown.errorDescription ?? "")
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func getExchangeRates(amount: Double,
                                  currency: Currency,
                                  _ complitionHandler: @escaping (Result<ExchangeRatesModel, Error>) -> Void) {
        let successHandler: (RatesModel) -> Void = { [weak self] model in
            if let termsUrl = URL(string: model.terms ?? "") {
                self?.terms = termsUrl
            }
            if let privacyPolicyUrl = URL(string: model.privacy ?? "") {
                self?.privacyPolicy = privacyPolicyUrl
            }
            let exchangeRates = model.generateExchangeRates(amount: amount, currency: currency)
            if exchangeRates.isEmpty {
                Self.defaults.rates = nil
                Self.defaults.exchangeRates = nil
                complitionHandler(.failure(ServiceError.unknown))
            } else {
                let model = ExchangeRatesModel(
                    amount: amount,
                    currency: currency,
                    items: exchangeRates
                )
                Self.defaults.exchangeRates = model
                complitionHandler(.success(model))
            }
        }
        
        if let model = currentValidModel {
            successHandler(model)
            return
        }
        
        ratesState = .loading
        loadRates { result in
            switch result {
            case let .success(model):
                successHandler(model)
            case let .failure(error):
                complitionHandler(.failure(error))
            }
        }
    }
    
    // MARK: - Network methods
    
    func cancelLoadingProcess() {
        loadingProcess?.cancel()
        loadingProcess = nil
    }
    
    private func loadRates(_ complitionHandler: @escaping (Result<RatesModel, Error>) -> Void) {
        cancelLoadingProcess()
        
        loadingProcess = service.loadDefaultRates()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.cancelLoadingProcess()
                guard case let .failure(error) = completion else { return }
                complitionHandler(.failure(error))
            }) { data in
                let model = data.toRatesModel
                Self.defaults.rates = model
                complitionHandler(.success(model))
            }
    }
}

// MARK: - String to Double

fileprivate extension String {
    
    var toDouble: Double {
        let digits = filter("-0123456789.,".contains).replacingOccurrences(of: ",", with: ".")
        return Double(digits) ?? 0
    }
}

// MARK: - Generate Exchange Rates

fileprivate extension RatesModel {
    
    func generateExchangeRates(amount: Double, currency: Currency) -> [ExchangeRateModel] {
        guard let sourceToCurrentQuota = quotes[currency], sourceToCurrentQuota != .zero else {
            return []
        }
        let sourceAmount = amount / sourceToCurrentQuota
        return quotes
            .map { currency, quote in
                ExchangeRateModel(
                    id: UUID(),
                    amount: sourceAmount * quote,
                    currency: currency,
                    quote: quote / sourceToCurrentQuota
                )
            }
            .sorted(by: { $0.currency.isoCode < $1.currency.isoCode })
    }
}

// MARK: - ExchangeRatesStore Defaults

fileprivate extension UserDefaults {
    
    static var exchangeRatesStore: UserDefaults {
        UserDefaults(suiteName: "\(Bundle.main.bundleIdentifier!).\(#function)")!
    }
    
    var amount: Double {
        get {
            double(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    
    var currency: Currency? {
        get {
            guard let iso = string(forKey: #function) else {
                return nil
            }
            return Currency(iso)
        }
        set {
            guard let value = newValue else {
                removeObject(forKey: #function)
                return
            }
            set(value.isoCode, forKey: #function)
        }
    }
    
    var exchangeRates: ExchangeRatesModel? {
        get {
            guard let data = data(forKey: #function) else {
                return nil
            }
            return try? JSONDecoder().decode(ExchangeRatesModel.self, from: data)
        }
        set {
            guard let value = newValue, let data = try? JSONEncoder().encode(value) else {
                removeObject(forKey: #function)
                return
            }
            set(data, forKey: #function)
        }
    }
    
    var rates: RatesModel? {
        get {
            guard let data = data(forKey: #function) else {
                return nil
            }
            return try? JSONDecoder().decode(RatesModel.self, from: data)
        }
        set {
            guard let value = newValue, let data = try? JSONEncoder().encode(value) else {
                removeObject(forKey: #function)
                return
            }
            set(data, forKey: #function)
        }
    }
}
