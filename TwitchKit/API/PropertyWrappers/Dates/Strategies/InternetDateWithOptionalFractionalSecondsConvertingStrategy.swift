//
//  InternetDateWithOptionalFractionalSecondsConvertingStrategy.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// A `CodableDate` whose wrapped value is converted using the
/// `InternetDateWithOptionalFractionalSecondsConvertingStrategy`.
public typealias InternetDateWithOptionalFractionalSeconds =
    CodableDate<InternetDateWithOptionalFractionalSecondsConvertingStrategy>

/// An `OptionalCodableDate` whose wrapped value is converted using the
/// `InternetDateWithOptionalFractionalSecondsConvertingStrategy`.
public typealias OptionalInternetDateWithOptionalFractionalSeconds =
    OptionalCodableDate<InternetDateWithOptionalFractionalSecondsConvertingStrategy>

/// A `CodableDateInterval` whose wrapped value is converted using the
/// `InternetDateWithOptionalFractionalSecondsConvertingStrategy`.
public typealias InternetDateIntervalWithOptionalFractionalSeconds =
    CodableDateInterval<InternetDateWithOptionalFractionalSecondsConvertingStrategy>

/// An `OptionalCodableDateInterval` whose wrapped value is converted using the
/// `InternetDateWithOptionalFractionalSecondsConvertingStrategy`.
public typealias OptionalInternetDateIntervalWithOptionalFractionalSeconds =
    OptionalCodableDateInterval<InternetDateWithOptionalFractionalSecondsConvertingStrategy>

/// A date converting strategy that uses an `ISO8601DateFormatter` with the `.withInternetDateTime`
/// and `.withFractionalSeconds` options to convert between `Date` and `String` values. If the strategy fails when
/// converting from a `String` to a `Date`, it then falls back to using an `ISO8601DateFormatter` with only the
/// `.withInternetDateTime` option specified and tries to convert the `String` into a `Date` again.
public enum InternetDateWithOptionalFractionalSecondsConvertingStrategy: DateConvertingStrategy {
    public static func date(from string: String) -> Date? {
        InternetDateWithFractionalSecondsConvertingStrategy
            .date(from: string) ?? InternetDateConvertingStrategy.date(from: string)
    }
    
    public static func string(from date: Date) -> String {
        InternetDateWithFractionalSecondsConvertingStrategy.string(from: date)
    }
}
