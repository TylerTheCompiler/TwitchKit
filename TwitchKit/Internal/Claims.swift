//
//  Claims.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// Describes the pieces of data you want to get about the user authorizing your application.
internal struct Claims: Codable, Equatable {
    
    /// The set of `Claim`s to be returned inside an ID token.
    internal let idTokenClaims: Set<Claim>
    
    /// The set of `Claim`s to be returned from the userinfo endpoint.
    internal let userinfoClaims: Set<Claim>
    
    /// Creates a new `Claims` instance with ID token claims and userinfo claims, or
    /// fails if both `idTokenClaims` and `userinfoClaims` are empty.
    ///
    /// - Parameters:
    ///   - idTokenClaims: A set of claims to be used for the ID token claims.
    ///   - userinfoClaims: A set of claims to be used for the userinfo claims.
    internal init?(idTokenClaims: Set<Claim>, userinfoClaims: Set<Claim>) {
        if idTokenClaims.isEmpty && userinfoClaims.isEmpty { return nil }
        self.idTokenClaims = idTokenClaims
        self.userinfoClaims = userinfoClaims
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var idTokenClaims = Set<Claim>()
        if let idTokenContainer = try? container.nestedContainer(keyedBy: Claim.self, forKey: .idToken) {
            for key in idTokenContainer.allKeys {
                if try idTokenContainer.decodeNil(forKey: key) {
                    idTokenClaims.insert(key)
                }
            }
        }
        
        var userinfoClaims = Set<Claim>()
        if let userinfoContainer = try? container.nestedContainer(keyedBy: Claim.self, forKey: .userinfo) {
            for key in userinfoContainer.allKeys {
                if try userinfoContainer.decodeNil(forKey: key) {
                    userinfoClaims.insert(key)
                }
            }
        }
        
        self.idTokenClaims = idTokenClaims
        self.userinfoClaims = userinfoClaims
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if !idTokenClaims.isEmpty {
            var idTokenContainer = container.nestedContainer(keyedBy: Claim.self, forKey: .idToken)
            for claim in idTokenClaims {
                try idTokenContainer.encodeNil(forKey: claim)
            }
        }
        
        if !userinfoClaims.isEmpty {
            var userinfoContainer = container.nestedContainer(keyedBy: Claim.self, forKey: .userinfo)
            for claim in userinfoClaims {
                try userinfoContainer.encodeNil(forKey: claim)
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case idToken
        case userinfo
    }
}
