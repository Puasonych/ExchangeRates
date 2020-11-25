//
//  ContentView.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 22/11/2020.
//

import SwiftUI
import Components
import Common

struct ContentView: View {
    
    // MARK: - Properties
    
    @StateObject var store = ExchangeRatesStore()
    
    // MARK: - Main
    
    var body: some View {
        NavigationView {
            List {
                Section(footer: topSectionFooter) {
                    AmountTextField()
                        .environmentObject(store)
                    
                    NavigationLink(destination: currencyList) {
                        currentCurrency
                    }
                }
                
                ratesContent
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Exchange Rates", displayMode: .inline)
        }
        .accentColor(.purple)
        .onAppear {
            store.prepare()
        }
    }
    
    // MARK: - Top section
    
    var topSectionFooter: some View {
        HStack {
            Spacer()
            ExchangeRatesButton()
                .environmentObject(store)
            Spacer()
        }
        .padding(.vertical, 10)
    }
    
    var currencyList: some View {
        CurrencyList()
            .environmentObject(store.currencyStore)
            .navigationBarTitle("Currencies", displayMode: .inline)
    }
    
    var currentCurrency: some View {
        HStack {
            Text("Currency")
            Spacer()
            Text(store.currency.isoCode)
        }
    }
    
    // MARK: - Bottom section
    
    @ViewBuilder
    var ratesContent: some View {
        switch store.ratesState {
        case .emptyContent:
            EmptyView()
        case let .content(model):
            Section(
                header: HStack(spacing: .zero) {
                    Text("Exchange rates for ")
                    Text("\(model.formattedAmount) \(model.currency.isoCode)")
                        .foregroundColor(.accentColor)
                },
                footer: termsAndPrivacy
            ) {
                ForEach(model.items) { item in
                    ratesItem(item)
                }
            }
            .textCase(nil)
        case let .error(text):
            Section(header: Text(text)) {}
                .textCase(nil)
        case .loading:
            Section(header: Text("Exchange rates are loading...")) {
                HStack {
                    Spacer()
                    LoadingIndicatorView().frame(width: 25, height: 25)
                    Spacer()
                }
            }
            .textCase(nil)
        }
    }
    
    var termsAndPrivacy: some View {
        TermsAndPrivacyView()
            .environmentObject(store)
    }
    
    // MARK: - Methods
    
    func ratesItem(_ model: ExchangeRateModel) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(model.currency.isoCode) \(model.formattedAmount)")
                    .font(.title2)
                Text("Quota: \(model.formattedQuota)")
                    .font(.caption2)
            }
            .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = model.copyText
                }) {
                    Text("Copy")
                }
            }
            
            Spacer()
            
            (model.currency.countryImage ?? Image(systemName: "camera.metering.unknown"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25)
        }
    }
}

// MARK: - Amount Text field

fileprivate struct AmountTextField: View {
    
    @EnvironmentObject var store: ExchangeRatesStore

    var body: some View {
        TextField("Enter amount", text: .init(
            get: { store.amount == .zero ? "" : "\(store.amount)" },
            set: { store.set(amount: $0) }
        ))
        .font(.title)
        .keyboardType(.decimalPad)
    }
}

// MARK: - Get exchange rates button

fileprivate struct ExchangeRatesButton: View {
    
    @EnvironmentObject var store: ExchangeRatesStore
    
    var body: some View {
        Button(action: {
            hideKeyboard()
            store.loadRates()
        }) {
            Image(systemName: "bolt")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
                .foregroundColor(.accentColor)
            Text("Get exchange rates")
        }
        .font(.body)
    }
}

// MARK: - Terms and privacy

fileprivate struct TermsAndPrivacyView: View {
    
    @EnvironmentObject var store: ExchangeRatesStore
    @State private var termsIsPresented: Bool = false
    @State private var privacyIsPresented: Bool = false
    
    var body: some View {
        HStack {
            Button("Terms & Conditions") {
                termsIsPresented = true
            }
            .sheet(isPresented: $termsIsPresented) {
                SafariView(store.terms)
            }
            
            Button("Privacy Policy") {
                privacyIsPresented = true
            }
            .sheet(isPresented: $privacyIsPresented) {
                SafariView(store.privacyPolicy)
            }
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
