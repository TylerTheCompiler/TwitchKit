//
//  CodingUserInfoKey+Extensions.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/29/20.
//

extension CodingUserInfoKey {
    internal static let expectedNonce = Self("expectedNonce")
    
    internal init(_ rawValue: String) {
        // swiftlint:disable:next force_unwrapping
        self.init(rawValue: rawValue)!
    }
}
