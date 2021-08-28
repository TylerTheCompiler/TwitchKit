//
//  ArrayOfOne.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

@propertyWrapper
public struct ArrayOfOne<T: Decodable> {
    public var wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

extension ArrayOfOne: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let firstValue = try container.decode([T].self).first else {
            throw DecodingError.valueNotFound(
                T.self,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Expected to decode \(T.self), but found empty array instead."
                )
            )
        }
        
        wrappedValue = firstValue
    }
}

extension ArrayOfOne: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([wrappedValue])
    }
}
