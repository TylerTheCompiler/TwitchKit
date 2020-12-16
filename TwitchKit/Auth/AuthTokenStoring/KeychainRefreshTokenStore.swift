//
//  KeychainRefreshTokenStore.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/8/20.
//

/// A `KeychainAuthTokenStore` that is used to fetch and store a `RefreshToken` to/from the default keychain.
open class KeychainRefreshTokenStore: KeychainAuthTokenStore<RefreshToken> {
    
    /// Creates a new refresh token store.
    ///
    /// - Parameter identifier: An additional optional identifier to add to the token's keychain item.
    ///                         Defaults to an empty string.
    public init(identifier: String = "") {
        super.init(keyKind: "refresh-token", identifier: identifier)
    }
    
    override internal func keychainItemLabel(withUserId userId: String?) -> String? {
        "Twitch Refresh Token (User ID: \(userId ?? "<unknown>"))"
    }
}
