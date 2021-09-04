//
//  IdToken.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// A wrapper around an ID token string.
public struct IdToken: RawRepresentable, Codable {
    
    /// An error that occurred during parsing of an `IdToken`.
    public enum ParseError: Swift.Error {
        
        /// The ID token is in an invalid format.
        case invalidFormat
        
        /// The nonce claim in the ID token's payload does not match the expected nonce value.
        case mismatchedNonce
        
        /// The ID token's payload is missing one or more values for default claims
        /// (e.g. "iss", "sub", "aud", "exp", "iat"), or the values are in an invalid or unexpected format.
        case missingOrInvalidDefaultClaims
    }
    
    /// Describes pieces of data you want to get about the user authorizing your application.
    public struct Claims {
        
        /// Token issuer (Twitch).
        public let iss: String
        
        /// Subject or end-user identifier.
        public let sub: String
        
        /// Audience or OAuth 2.0 client that is the intended recipient of the token.
        public let aud: String
        
        /// Expiration time (note that when the ID tokens expire, they cannot be refreshed).
        public let exp: Date
        
        /// Issuance time.
        public let iat: Date
        
        /// Email address of the authorizing user.
        public let email: String?
        
        /// Email verification state of the authorizing user.
        public let isEmailVerified: Bool?
        
        /// Profile image URL of the authorizing user.
        public let pictureURL: URL?
        
        /// Display name of the authorizing user.
        public let preferredUsername: String?
        
        /// Date of the last update to the authorizing user's profile.
        public let updatedDate: Date?
    }
    
    /// The raw string value of the ID token.
    public let stringValue: String
    
    /// The ID token's header dictionary.
    public let header: [String: Any]
    
    /// The ID token's payload dictionary.
    public let payload: [String: Any]
    
    /// The raw signature value of the ID token.
    public let signature: String
    
    /// The set of claim values contained in the payload.
    public let claims: Claims
    
    /// Creates an `IdToken` from a raw string value and (optionally) a nonce value to check against.
    ///
    /// If `shouldValidateNonce` is true and the nonce in the parsed ID token's payload does not match
    /// `expectedNonce`, then the error `ParseError.mismatchedNonce` is thrown. If `shouldValidateNonce` is
    /// false, the nonce is not validated against `expectedNonce`.
    ///
    /// - Parameters:
    ///   - stringValue: The raw string value to parse in order to create the `IdToken`.
    ///   - expectedNonce: The nonce value that was used in the authentication request. Default: nil.
    ///   - shouldValidateNonce: Whether the nonce should be validated or not. Default: true.
    /// - Throws:
    ///   * `ParseError.invalidFormat` if the ID token is in an invalid or unrecognized format.
    ///   * `ParseError.mismatchedNonce` if the nonce in the payload does not match `expectedNonce` and
    ///                                  `shouldValidateNonce` is true.
    ///   * `ParseError.missingOrInvalidDefaultClaims` if the payload's default claims are either missing or in an
    ///                                                invalid or unrecognized format.
    public init(stringValue: String,
                expectedNonce: String? = nil,
                shouldValidateNonce: Bool = true) throws {
        self.stringValue = stringValue
        
        let components = stringValue.components(separatedBy: ".")
        guard components.count == 3 else { throw ParseError.invalidFormat }
        
        guard let headerData = components[0].base64URLDecodedData,
              let payloadData = components[1].base64URLDecodedData,
              let headerDict = try JSONSerialization.jsonObject(with: headerData) as? [String: Any],
              let payloadDict = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            throw ParseError.invalidFormat
        }
        
        if shouldValidateNonce {
            guard expectedNonce == payloadDict["nonce"] as? String else {
                throw ParseError.mismatchedNonce
            }
        }
        
        header = headerDict
        payload = payloadDict
        signature = components[2]
        
        guard let iss = payloadDict["iss"] as? String,
              let sub = payloadDict["sub"] as? String,
              let aud = payloadDict["aud"] as? String,
              let exp = (payloadDict["exp"] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) }),
              let iat = (payloadDict["iat"] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) }) else {
            throw ParseError.missingOrInvalidDefaultClaims
        }
        
        claims = .init(
            iss: iss,
            sub: sub,
            aud: aud,
            exp: exp,
            iat: iat,
            email: payloadDict["email"] as? String,
            isEmailVerified: payloadDict["email_verified"] as? Bool,
            pictureURL: (payloadDict["picture"] as? String).flatMap { URL(string: $0) },
            preferredUsername: payloadDict["preferred_username"] as? String,
            updatedDate: (payloadDict["updated_at"] as? String).flatMap {
                ISO8601DateFormatter.internetDateWithFractionalSecondsFormatter.date(from: $0)
            }
        )
    }
    
    public var rawValue: String {
        stringValue
    }
    
    public init?(rawValue: String) {
        try? self.init(stringValue: rawValue, shouldValidateNonce: false)
    }
    
    public init(from decoder: Decoder) throws {
        let expectedNonce = decoder.userInfo[.expectedNonce] as? String
        try self.init(stringValue: decoder.singleValueContainer().decode(String.self),
                      expectedNonce: expectedNonce)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}
