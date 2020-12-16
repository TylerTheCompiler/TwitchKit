//
//  DateConvertingStrategy.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

/// A type that can statically convert between `Date` and `String` types.
public protocol DateConvertingStrategy {
    
    /// Returns a `Date` given a `String` value. If a date cannot be created from the string, returns nil.
    ///
    /// - Parameter string: The string to create the date from.
    /// - Returns: A date if `string` can be converted into a `Date`; nil otherwise.
    static func date(from string: String) -> Date?
    
    /// Returns a `String` representing a given `Date` value.
    ///
    /// - Parameter date: The date to create the string from.
    /// - Returns: A string representing the given date.
    static func string(from date: Date) -> String
}
