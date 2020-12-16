//
//  KeychainUserAccessTokenStore.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/8/20.
//

/// A `KeychainAuthTokenStore` that is used to fetch and store a `ValidatedUserAccessToken`
/// to/from the default keychain.
open class KeychainUserAccessTokenStore: KeychainAuthTokenStore<ValidatedUserAccessToken> {
    
    /// Creates a new user access token store.
    ///
    /// - Parameters:
    ///   - synchronizesOveriCloud: Whether the user access token should be synchronized over iCloud or not.
    ///                             Defaults to false.
    ///   - identifier: An additional optional identifier to add to the access token's keychain item.
    ///                 Defaults to an empty string.
    public init(synchronizesOveriCloud: Bool = false, identifier: String = "") {
        super.init(synchronizesOveriCloud: synchronizesOveriCloud,
                   keyKind: "user-access-token",
                   identifier: identifier)
    }
    
    override internal func keychainItemLabel(withUserId userId: String?) -> String? {
        "Twitch User Access Token (User ID: \(userId ?? "<unknown>"))"
    }
}
