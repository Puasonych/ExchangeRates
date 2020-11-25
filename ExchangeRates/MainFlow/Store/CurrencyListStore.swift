//
//  CurrencyListStore.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation
import Common
import Combine

final class CurrencyListStore: ObservableObject {
    
    // MARK: - Nested types
    
    enum Constants {
        static let validDataTimeinterval: TimeInterval = 30 * 60
    }
    
    typealias ItemModel = (title: String?, currency: Currency)
    
    enum State {
        case emptyContent
        case content(current: ItemModel, items: [ItemModel])
        case loading
        case error(String)
    }
    
    // MARK: - Properties
    
    @Published private(set) var state: State = .emptyContent
    
    // MARK: - Private properties
    
    private weak var output: CurrencyListOutputProtocol?
    private var currentCurrency: Currency = .default
    
    private lazy var defaults = UserDefaults.currencyListStore
    private lazy var service = ExchangeRatesService()
    private var loadingProcess: AnyCancellable?
    
    // MARK: - Computed properties
    
    private var currentValidModel: CurrenciesModel? {
        guard let model = defaults.currencies else {
            return nil
        }
        let currentDate = Date()
        return (model.timestamp < currentDate && model.timestamp.distance(to: currentDate) > Constants.validDataTimeinterval)
            ? nil
            : model
    }
    
    // MARK: - Methods
    
    func configure(currency: Currency) {
        self.currentCurrency = currency
    }
    
    func configure(output: CurrencyListOutputProtocol? = nil) {
        self.output = output
    }
    
    func prepare() {
        let currentCurrency = self.currentCurrency
        prepareRates { [weak self] result in
            switch result {
            case let .success(model):
                let items: [ItemModel] = model.currencies
                    .reduce([]) { $0 + [($1.value, $1.key)] }
                    .sorted(by: { $0.0 < $1.0 })
                let currentItem: ItemModel = (title: model.currencies[currentCurrency], currency: currentCurrency)
                self?.state = .content(current: currentItem, items: items)
            case let .failure(error):
                switch error {
                case let error as CurrencylayerError:
                    self?.state = .error(error.info)
                default:
                    self?.state = .error(ServiceError.unknown.errorDescription ?? "")
                }
            }
        }
    }

    func set(currency: Currency) {
        self.currentCurrency = currency
        output?.set(currency: currency)
    }
    
    // MARK: - Private methods
    
    private func prepareRates(_ complitionHandler: @escaping (Result<CurrenciesModel, Error>) -> Void) {
        if let model = currentValidModel {
            complitionHandler(.success(model))
            return
        }
        state = .loading
        loadRates(complitionHandler)
    }
    
    // MARK: - Network methods
    
    func cancelLoadingProcess() {
        loadingProcess?.cancel()
        loadingProcess = nil
    }
    
    private func loadRates(_ complitionHandler: @escaping (Result<CurrenciesModel, Error>) -> Void) {
        cancelLoadingProcess()
        
        loadingProcess = service.loadCurrencies()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.cancelLoadingProcess()
                guard case let .failure(error) = completion else { return }
                complitionHandler(.failure(error))
            }) { [weak self] data in
                let model = data.toCurrenciesModel
                self?.defaults.currencies = model
                complitionHandler(.success(model))
            }
    }
}

// MARK: - ExchangeRatesStore Defaults

fileprivate extension UserDefaults {
    
    static var currencyListStore: UserDefaults {
        return UserDefaults(suiteName: "\(Bundle.main.bundleIdentifier!).\(#function)")!
    }
    
    var currencies: CurrenciesModel? {
        get {
            guard let data = data(forKey: #function) else {
                return nil
            }
            return try? JSONDecoder().decode(CurrenciesModel.self, from: data)
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

