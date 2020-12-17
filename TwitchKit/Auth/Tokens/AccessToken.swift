//
//  AccessToken.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// An auth token that can be used to access various Twitch APIs.
public protocol AccessToken: AuthToken {
    
    /// A type that holds metadata relating to the validation of this kind of `AccessToken`.
    associatedtype Validation: AccessTokenValidation
    
    /// A type that is the validated version of this kind of `AccessToken`.
    associatedtype ValidAccessTokenType: ValidatedAccessToken where ValidAccessTokenType.Validation == Validation
    
    /// The raw string value of the access token.
    var stringValue: String { get }
}

/// The protocol that all access token validations conform to. Implementors must be able to return the date
/// of the last validation of an access token.
public protocol AccessTokenValidation: Equatable, Codable {
    
    /// The last validation date of an access token.
    var date: Date { get }
}

extension AccessTokenValidation {
    
    /// Whether the validation's access token was validated recently or not.
    var isRecent: Bool {
        date > Date() - 45 * 60
    }
}

/// An access token that has been validated at some point.
public protocol ValidatedAccessToken: AccessToken where ValidAccessTokenType == Self {
    
    /// The type of this type's unvalidated access token form.
    associatedtype UnvalidatedAccessTokenType: AccessToken where
        UnvalidatedAccessTokenType.ValidAccessTokenType == Self,
        UnvalidatedAccessTokenType.Validation == Validation
    
    /// Contains information pertaining to the last validation of the access token.
    var validation: Validation { get }
    
    /// Returns a copy of this access token without the validation.
    var unvalidated: UnvalidatedAccessTokenType { get }
    
    /// Creates a new access token from a raw string value and a validation object.
    ///
    /// - Parameters:
    ///   - stringValue: The raw access token.
    ///   - validation: A validation of the access token.
    init(stringValue: String, validation: Validation)
}
