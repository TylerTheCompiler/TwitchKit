//
//  AuthCode.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// A wrapper around an authorization code string.
public struct AuthCode: RawRepresentable, Codable {
    
    /// The raw string value of the auth code.
    public let rawValue: String
    
    /// Creates an `AuthCode` from a raw string value.
    ///
    /// - Parameter rawValue: The raw string value to create the auth code from.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
