//
//  Currency.swift
//  TripCost
//
//  Created by Migration on 2025-10-20.
//

import Foundation

struct Currency: Codable, Hashable, Identifiable {
    let id: String // ISO code, e.g. "USD"
    let symbol: String
    let name: String

    static let all: [Currency] = Locale.commonISOCurrencyCodes.compactMap { code in
        let locale = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }.first { $0.currencyCode == code }
        let symbol = locale?.currencySymbol ?? code
        let name = locale?.localizedString(forCurrencyCode: code) ?? code
        return Currency(id: code, symbol: symbol, name: name)
    }.sorted { $0.name < $1.name }

    static let `default` = Currency(id: "USD", symbol: "$", name: "US Dollar")
}
