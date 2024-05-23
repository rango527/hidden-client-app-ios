//
//  HCDate.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/07.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import Foundation

extension Date {
    var dayTh: String {
        let calendar = Calendar.current
        let dateComponents = calendar.component(.day, from: self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        return numberFormatter.string(from: dateComponents as NSNumber) ?? ""
    }
}
