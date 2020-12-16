//
//  KeychainAppAccessTokenStore.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/8/20.
//

/// A `KeychainAuthTokenStore` that is used to fetch and store a `ValidatedAppAccessToken`
/// to/from the default keychain.
open class KeychainAppAccessTokenStore: KeychainAuthTokenStore<ValidatedAppAccessToken> {
    
    /// Creates a new app access token store.
    ///
    /// - Parameter identifier: An additional optional identifier to add to the access token's keychain item.
    ///                         Defaults to an empty string.
    public init(identifier: String = "") {
        super.init(keyKind: "app-access-token", identifier: identifier)
    }
    
    override internal func keychainItemLabel(withUserId userId: String?) -> String? {
        "Twitch App Access Token"
    }
}
