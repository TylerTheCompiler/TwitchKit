//
//  IncompatibleAccessToken.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// A type that denotes an access token that is incompatible with certain API requests.
///
/// This type cannot be instantiated. Do not use this type, as it is merely used for
/// classifying API requests by which types of access tokens they require.
///
/// If you try to instantiate this type, you will get a fatal error.
public struct IncompatibleAccessToken: AccessToken, ValidatedAccessToken {
    public typealias UnvalidatedAccessTokenType = Self
    public typealias ValidAccessTokenType = Self
    
    /// Unused
    public struct Validation: AccessTokenValidation {
        
        /// Unused
        public var date: Date { fatalError() }
        
        private init() {}
    }
    
    /// Unused
    public var stringValue: String { fatalError() }
    
    /// Unused
    public var validation: Validation { fatalError() }
    
    /// Unused
    public var unvalidated: IncompatibleAccessToken { fatalError() }
    
    /// **Do not call this initializer! You will get a fatal error!**
    ///
    /// - Parameters:
    ///   - stringValue: Unused
    ///   - validation: Unused
    public init(stringValue: String, validation: Validation) {
        fatalError("Do not instantiate \(IncompatibleAccessToken.self)")
    }
}
