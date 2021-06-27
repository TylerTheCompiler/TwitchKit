//
//  OptionalCodableDateInterval.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

/// Generic property wrapper for an optional `DateInterval` that encodes/decodes its wrapped value according
/// to a `DateConvertingStrategy`.
@propertyWrapper
public struct OptionalCodableDateInterval<Strategy>: Codable where Strategy: DateConvertingStrategy {
    
    /// The wrapped date interval value.
    public var wrappedValue: DateInterval?
    
    /// Creates a new `OptionalCodableDateInterval`.
    ///
    /// - Parameter wrappedValue: The wrapped date interval value.
    public init(wrappedValue: DateInterval?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let startedAtString = try container.decode(String.self, forKey: .startedAt)
            let endedAtString = try container.decode(String.self, forKey: .endedAt)
            
            guard let startedAt = Strategy.date(from: startedAtString),
                  let endedAt = Strategy.date(from: endedAtString),
                  endedAt >= startedAt else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid date range."
                ))
            }
            
            self.init(wrappedValue: .init(start: startedAt, end: endedAt))
        } catch {
            self.init(wrappedValue: nil)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let wrappedValue = wrappedValue else {
            try container.encodeNil(forKey: .startedAt)
            try container.encodeNil(forKey: .endedAt)
            return
        }
        
        try container.encode(Strategy.string(from: wrappedValue.start), forKey: .startedAt)
        try container.encode(Strategy.string(from: wrappedValue.end), forKey: .endedAt)
    }
    
    private enum CodingKeys: String, CodingKey {
        case startedAt
        case endedAt
    }
}

extension KeyedDecodingContainer {
    public func decode<T>(_ type: OptionalCodableDateInterval<T>.Type,
                          forKey key: Key) throws -> OptionalCodableDateInterval<T> where T: Decodable {
        try decodeIfPresent(type, forKey: key) ?? OptionalCodableDateInterval(wrappedValue: nil)
    }
}
