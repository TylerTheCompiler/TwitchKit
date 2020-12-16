//
//  CodableDate.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

/// Generic property wrapper for a `Date` that encodes/decodes its wrapped value according
/// to a `DateConvertingStrategy`.
@propertyWrapper
public struct CodableDate<Strategy>: Codable where Strategy: DateConvertingStrategy {
    
    /// The wrapped date value.
    public var wrappedValue: Date
    
    /// Creates a new `CodableDate`.
    ///
    /// - Parameter wrappedValue: The wrapped date value.
    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        if let date = Strategy.date(from: dateString) {
            wrappedValue = date
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date string")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Strategy.string(from: wrappedValue))
    }
}
