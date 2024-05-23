//
//  HCNumberFormatter.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/03.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import Foundation

class HCNumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale                = Locale(identifier: "en_GB")
        formatter.usesGroupingSeparator = true
        formatter.numberStyle           = .currencyAccounting
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()
    static func ukCurrency(_ from: String?) -> String {
        return HCNumberFormatter.currency.string(from: NSNumber(integerLiteral: Int(Double(from ?? "0.0") ?? 0.0))) ?? ""
    }
}
