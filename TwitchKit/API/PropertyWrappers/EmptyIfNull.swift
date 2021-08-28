//
//  EmptyIfNull.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

@propertyWrapper
public struct EmptyIfNull<C: RangeReplaceableCollection> {
    public var wrappedValue: C
    
    public init(wrappedValue: C) {
        self.wrappedValue = wrappedValue
    }
}

extension EmptyIfNull: Decodable where C: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            wrappedValue = .init()
        } else {
            wrappedValue = try container.decode(C.self)
        }
    }
}

extension EmptyIfNull: Encodable where C: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if wrappedValue.isEmpty {
            try container.encodeNil()
        } else {
            try container.encode(wrappedValue)
        }
    }
}
