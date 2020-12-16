//
//  RefreshToken.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// A wrapper around a refresh token string.
public struct RefreshToken: AuthToken, Codable {
    
    /// The raw string value of the refresh token.
    public let rawValue: String
    
    /// Creates a `RefreshToken` from a raw string value.
    ///
    /// - Parameter rawValue: The raw string value to create the refresh token from.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: decoder.singleValueContainer().decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
