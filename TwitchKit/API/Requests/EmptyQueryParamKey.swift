//
//  EmptyQueryParamKey.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// A type that represents the absense of query parameters of an API request.
public struct EmptyQueryParamKey: RawRepresentable, Equatable {
    
    /// Unused.
    public let rawValue: String
    
    /// Returns nil.
    ///
    /// - Parameter rawValue: Unused.
    public init?(rawValue: String) { return nil }
}
