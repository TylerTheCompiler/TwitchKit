//
//  BinaryIntegery+Extensions.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 11/19/20.
//

import Foundation

extension BinaryInteger where Self: ConvertibleToNSNumber {
    var ordinalString: String {
        NumberFormatter.localizedString(from: nsNumberValue, number: .ordinal)
    }
    
    var decimalString: String {
        NumberFormatter.localizedString(from: nsNumberValue, number: .decimal)
    }
}
