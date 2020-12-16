//
//  InternetDateConvertingStrategy.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

/// A `CodableDate` whose wrapped value is converted using the `InternetDateConvertingStrategy`.
public typealias InternetDate = CodableDate<InternetDateConvertingStrategy>

/// An `OptionalCodableDate` whose wrapped value is converted using the `InternetDateConvertingStrategy`.
public typealias OptionalInternetDate = OptionalCodableDate<InternetDateConvertingStrategy>

/// A `CodableDateInterval` whose wrapped value is converted using the `InternetDateConvertingStrategy`.
public typealias InternetDateInterval = CodableDateInterval<InternetDateConvertingStrategy>

/// An `OptionalCodableDateInterval` whose wrapped value is converted using the `InternetDateConvertingStrategy`.
public typealias OptionalInternetDateInterval = OptionalCodableDateInterval<InternetDateConvertingStrategy>

/// A date converting strategy that uses an `ISO8601DateFormatter` with the `.withInternetDateTime` option
/// to convert between `Date` and `String` values.
public enum InternetDateConvertingStrategy: DateConvertingStrategy {
    public static func date(from string: String) -> Date? {
        ISO8601DateFormatter.internetDateFormatter.date(from: string)
    }
    
    public static func string(from date: Date) -> String {
        ISO8601DateFormatter.internetDateFormatter.string(from: date)
    }
}
