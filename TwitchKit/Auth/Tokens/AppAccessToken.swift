//
//  AppAccessToken.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// A wrapper around an app access token string.
public struct AppAccessToken: AccessToken {
    public typealias Validation = ValidatedAppAccessToken.Validation
    public typealias ValidAccessTokenType = ValidatedAppAccessToken
    
    /// The raw string value of the app access token.
    public let stringValue: String
    
    /// Creates an `AppAccessToken` from a raw string value.
    ///
    /// - Parameter stringValue: The raw string value to create an app access token from.
    public init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public init(from decoder: Decoder) throws {
        stringValue = try decoder.singleValueContainer().decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

/// An app access token that has been validated at some point.
public struct ValidatedAppAccessToken: ValidatedAccessToken {
    public typealias ValidAccessTokenType = Self
    public typealias UnvalidatedAccessTokenType = AppAccessToken
    
    /// A structure representing a successful validation of an app access token.
    public struct Validation: AccessTokenValidation {
        
        /// The client ID of the application that validated the app access token.
        public let clientId: String
        
        /// The set of scopes that were requested along with the app access token.
        public let scopes: Set<Scope>
        
        /// The last validation date of the access token.
        public let date: Date
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            clientId = try container.decode(String.self, forKey: .clientId)
            scopes = try container.decode(Set<Scope>.self, forKey: .scopes)
            date = (try? container.decodeIfPresent(Date.self, forKey: .date)) ?? Date()
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(clientId, forKey: .clientId)
            try container.encode(scopes, forKey: .scopes)
            try container.encode(date, forKey: .date)
        }
        
        internal init(clientId: String, scopes: Set<Scope>, date: Date) {
            self.clientId = clientId
            self.scopes = scopes
            self.date = date
        }
        
        private enum CodingKeys: String, CodingKey {
            case clientId
            case scopes
            case date
        }
    }
    
    /// The raw string value of the access token.
    public let stringValue: String
    
    /// Contains information pertaining to the last validation of the access token.
    public let validation: Validation
    
    /// Returns a copy of this access token without the validation.
    public var unvalidated: AppAccessToken {
        .init(stringValue: stringValue)
    }
    
    /// Creates a new access token from a raw string value and a validation object.
    ///
    /// - Parameters:
    ///   - stringValue: The raw access token.
    ///   - validation: A validation of the access token.
    public init(stringValue: String, validation: Validation) {
        self.stringValue = stringValue
        self.validation = validation
    }
}
