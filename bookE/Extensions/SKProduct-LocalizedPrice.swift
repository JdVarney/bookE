//
//  SKProduct-LocalizedPrice.swift
//  bookE
//
//  Created by John Varney on 12/4/21.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }

}
