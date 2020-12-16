//
//  UserAccessToken.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// A wrapper around a user access token string.
public struct UserAccessToken: AccessToken {
    public typealias Validation = ValidatedUserAccessToken.Validation
    public typealias ValidAccessTokenType = ValidatedUserAccessToken
    
    /// The raw string value of the user access token.
    public let stringValue: String
    
    /// Creates a `UserAccessToken` from a raw string value.
    ///
    /// - Parameter stringValue: The raw string value to create the user access token from.
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

/// A user access token that has been validated at some point.
public struct ValidatedUserAccessToken: ValidatedAccessToken {
    public typealias ValidAccessTokenType = Self
    public typealias UnvalidatedAccessTokenType = UserAccessToken
    
    /// A structure representing a successful validation of a user access token.
    public struct Validation: AccessTokenValidation {
        
        /// The authorized user ID of the user that the user access token is for.
        public let userId: String
        
        /// The authorized login of the user that the user access token is for.
        public let login: String
        
        /// The client ID of the application that validated the user access token.
        public let clientId: String
        
        /// The set of scopes that were requested along with the user access token.
        public let scopes: Set<Scope>
        
        /// The date of the validation.
        public let date: Date
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userId = try container.decode(String.self, forKey: .userId)
            login = try container.decode(String.self, forKey: .login)
            clientId = try container.decode(String.self, forKey: .clientId)
            scopes = try container.decode(Set<Scope>.self, forKey: .scopes)
            date = (try? container.decodeIfPresent(Date.self, forKey: .date)) ?? Date()
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(userId, forKey: .userId)
            try container.encode(login, forKey: .login)
            try container.encode(clientId, forKey: .clientId)
            try container.encode(scopes, forKey: .scopes)
            try container.encode(date, forKey: .date)
        }
        
        internal init(userId: String, login: String, clientId: String, scopes: Set<Scope>, date: Date) {
            self.userId = userId
            self.login = login
            self.clientId = clientId
            self.scopes = scopes
            self.date = date
        }
        
        private enum CodingKeys: String, CodingKey {
            case userId
            case login
            case clientId
            case scopes
            case date
        }
    }
    
    /// The raw access token itself.
    public let stringValue: String
    
    /// The access token's last validation.
    public let validation: Validation
    
    /// The unvalidated version of the access token.
    public var unvalidated: UserAccessToken {
        .init(stringValue: stringValue)
    }
    
    /// Creates a new instance from a raw string value and a validation.
    ///
    /// - Parameters:
    ///   - stringValue: The raw access token itself.
    ///   - validation: A validation of the access token.
    public init(stringValue: String, validation: Validation) {
        self.stringValue = stringValue
        self.validation = validation
    }
}
