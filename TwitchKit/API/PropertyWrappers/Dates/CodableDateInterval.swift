//
//  CodableDateInterval.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Generic property wrapper for a `DateInterval` that encodes/decodes its wrapped value according
/// to a `DateConvertingStrategy`.
@propertyWrapper
public struct CodableDateInterval<Strategy>: Codable where Strategy: DateConvertingStrategy {
    
    /// The wrapped date interval value.
    public var wrappedValue: DateInterval
    
    /// Creates a new `CodableDateInterval`.
    ///
    /// - Parameter wrappedValue: The wrapped date interval value.
    public init(wrappedValue: DateInterval) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
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
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Strategy.string(from: wrappedValue.start), forKey: .startedAt)
        try container.encode(Strategy.string(from: wrappedValue.end), forKey: .endedAt)
    }
    
    private enum CodingKeys: String, CodingKey {
        case startedAt
        case endedAt
    }
}
