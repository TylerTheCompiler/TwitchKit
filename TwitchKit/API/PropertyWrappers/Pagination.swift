//
//  Pagination.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// A property wrapper of a `Cursor` value, to be used in subsequent requests that support pagination to specify the
/// starting point of the next or previous set of results.
@propertyWrapper
public struct Pagination: Decodable {
    
    /// A pagination cursor for a specific direction (forward or reverse).
    public enum DirectedCursor {
        
        /// Contains a cursor where the direction of pagination is forward.
        case forward(Cursor)
        
        /// Contains a cursor where the direction of pagination is backward.
        case backward(Cursor)
        
        /// The raw string value of the forward cursor, or nil if this value is a backward cursor.
        public var forwardRawValue: String? {
            switch self {
            case .forward(let cursor):
                return cursor.rawValue
                
            case .backward:
                return nil
            }
        }
        
        /// The raw string value of the backward cursor, or nil if this value is a forward cursor.
        public var backwardRawValue: String? {
            switch self {
            case .backward(let cursor):
                return cursor.rawValue
                
            case .forward:
                return nil
            }
        }
    }
    
    /// A value wrapping a string, to be used in subsequent requests that support pagination to specify the starting
    /// point of the next or previous set of results.
    public struct Cursor {
        
        /// The value used in subsequent requests that support pagination to specify the starting point of the next or
        /// previous set of results.
        public let rawValue: String
        
        /// Creates a cursor from a raw string value.
        ///
        /// - Parameter rawValue: The raw string value to create the cursor from.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    /// The wrapped `Cursor` value.
    public var wrappedValue: Cursor?
    
    public init(from decoder: Decoder) throws {
        if let keyedContainer = try? decoder.container(keyedBy: CodingKeys.self) {
            wrappedValue = try? .init(rawValue: keyedContainer.decode(String.self, forKey: .cursor))
        } else {
            let singleValueContainer = try decoder.singleValueContainer()
            wrappedValue = try? .init(rawValue: singleValueContainer.decode(String.self))
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case cursor
    }
}
