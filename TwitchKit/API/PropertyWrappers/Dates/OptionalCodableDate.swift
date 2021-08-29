//
//  OptionalCodableDate.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

/// Generic property wrapper for an optional `Date` that encodes/decodes its wrapped value according
/// to a `DateConvertingStrategy`.
@propertyWrapper
public struct OptionalCodableDate<Strategy>: Codable where Strategy: DateConvertingStrategy {
    
    /// The wrapped date value.
    public var wrappedValue: Date?
    
    /// Creates a new `OptionalCodableDate`.
    ///
    /// - Parameter wrappedValue: The wrapped date value.
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            wrappedValue = nil
        } else {
            let dateString = try container.decode(String.self)
            wrappedValue = Strategy.date(from: dateString)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = wrappedValue {
            try container.encode(Strategy.string(from: date))
        } else {
            try container.encodeNil()
        }
    }
}

extension KeyedDecodingContainer {
    public func decode<T>(_ type: OptionalCodableDate<T>.Type,
                          forKey key: Key) throws -> OptionalCodableDate<T> where T: Decodable {
        try decodeIfPresent(type, forKey: key) ?? OptionalCodableDate(wrappedValue: nil)
    }
}
