//
//  SafeURL.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/16/20.
//

/// <#Description#>
@propertyWrapper
public struct SafeURL: Codable {
    
    /// <#Description#>
    public var wrappedValue: URL?
    
    /// <#Description#>
    ///
    /// - Parameter wrappedValue: <#wrappedValue description#>
    public init(wrappedValue: URL?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        if let urlString = try? decoder.singleValueContainer().decode(String.self) {
            wrappedValue = URL(string: urlString)
        } else {
            wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension KeyedDecodingContainer {
    public func decode(_ type: SafeURL.Type, forKey key: Key) throws -> SafeURL {
        try decodeIfPresent(type, forKey: key) ?? SafeURL(wrappedValue: nil)
    }
}
