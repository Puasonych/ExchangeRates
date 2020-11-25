//
//  CurrencyList.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 24/11/2020.
//

import SwiftUI
import Common
import Components

struct CurrencyList: View {
    
    // MARK: - Properties
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: CurrencyListStore
    
    // MARK: - Computed properties
    
    var body: some View {
        List {
            switch store.state {
            case .emptyContent:
                EmptyView()
            case let .error(text):
                Section(header: Text(text)) {}
                    .textCase(nil)
            case .loading:
                Section(header: Text("Currencies are loading...")) {
                    HStack {
                        Spacer()
                        LoadingIndicatorView().frame(width: 25, height: 25)
                        Spacer()
                    }
                }
                .textCase(nil)
            case let .content(currentItem, items):
                Section(header: headerView(title: currentItem.title, currency: currentItem.currency)) {
                    ForEach(items, id: \.currency) { item in
                        itemView(title: item.title, currency: item.currency)
                    }
                }
                .textCase(nil)
            }
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            store.prepare()
        }
    }
    
    // MARK: - Methods
    
    func headerView(title: String?, currency: Currency) -> some View {
        HStack {
            if let title = title {
                Text("Current currency: \(title) (\(currency.isoCode))")
            } else {
                Text("Current currency: \(currency.isoCode)")
            }
        }
    }
    
    func itemView(title: String?, currency: Currency) -> some View {
        Button(action: {
            store.set(currency: currency)
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                (currency.countryImage ?? Image(systemName: "camera.metering.unknown"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                    .foregroundColor(.black)
                VStack(alignment: .leading) {
                    Text(title ?? "")
                        .font(.title3)
                    Text(currency.isoCode)
                        .font(.subheadline)
                }
                .foregroundColor(.black)
            }
        }
    }
}

// MARK: - Previews

struct CurrencyList_Previews: PreviewProvider {
    
    static var previews: some View {
        CurrencyList()
            .environmentObject(CurrencyListStore())
    }
}
