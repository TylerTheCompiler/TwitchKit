//
//  InternetDateWithFractionalSecondsConvertingStrategy.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

/// A `CodableDate` whose wrapped value is converted using the
/// `InternetDateWithFractionalSecondsConvertingStrategy`.
public typealias InternetDateWithFractionalSeconds =
    CodableDate<InternetDateWithFractionalSecondsConvertingStrategy>

/// An `OptionalCodableDate` whose wrapped value is converted using the
/// `InternetDateWithFractionalSecondsConvertingStrategy`.
public typealias OptionalInternetDateWithFractionalSeconds =
    OptionalCodableDate<InternetDateWithFractionalSecondsConvertingStrategy>

/// A `CodableDateInterval` whose wrapped value is converted using the
/// `InternetDateWithFractionalSecondsConvertingStrategy`.
public typealias InternetDateIntervalWithFractionalSeconds =
    CodableDateInterval<InternetDateWithFractionalSecondsConvertingStrategy>

/// An `OptionalCodableDateInterval` whose wrapped value is converted using the
/// `InternetDateWithFractionalSecondsConvertingStrategy`.
public typealias OptionalInternetDateIntervalWithFractionalSeconds =
    OptionalCodableDateInterval<InternetDateWithFractionalSecondsConvertingStrategy>

/// A date converting strategy that uses an `ISO8601DateFormatter` with the `.withInternetDateTime`
/// and `.withFractionalSeconds` options to convert between `Date` and `String` values.
public enum InternetDateWithFractionalSecondsConvertingStrategy: DateConvertingStrategy {
    public static func date(from string: String) -> Date? {
        if let date = ISO8601DateFormatter.internetDateWithFractionalSecondsFormatter.date(from: string) {
            return date
        }
        
        return DateFormatter.longFormatWithFractionalSecondsDateFormatter.date(from: string)
    }
    
    public static func string(from date: Date) -> String {
        ISO8601DateFormatter.internetDateWithFractionalSecondsFormatter.string(from: date)
    }
}
