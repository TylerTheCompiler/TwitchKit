//
//  AuthTokenStoring.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// A type that has the ability to synchronously or asynchronously store and retrieve a type of `AuthToken`.
public protocol AuthTokenStoring {
    
    /// The type of `AuthToken` that this `AuthTokenStoring` fetches and stores.
    associatedtype Token: AuthToken
    
    /// Retrieves an auth token for an optional user ID.
    ///
    /// - Parameters:
    ///   - userId: The user ID of the auth token to fetch, or nil if the auth token type does not apply to a user.
    ///   - completion: A closure to be called when fetching of the auth token is complete.
    ///   - result: The result of the fetch containing either the auth token or an error.
    func fetchAuthToken(forUserId userId: String?, completion: @escaping (_ result: Result<Token, Error>) -> Void)
    
    /// Stores or removes an auth token, for an optional user ID.
    ///
    /// - Parameters:
    ///   - token: The auth token to store, or nil to remove the auth token from storage.
    ///   - userId: The user ID of the auth token to store or remove, or nil if the auth token type does not apply to
    ///             a user.
    ///   - completion: A closure to be called when storing of the auth token is complete. The `error` parameter
    ///                 contains any error that prevented the storage of the auth token.
    func store(authToken: Token?, forUserId userId: String?, completion: ((_ error: Error?) -> Void)?)
}

extension AuthTokenStoring {
    
    /// Removes an auth token for an optional user ID.
    ///
    /// - Parameters:
    ///   - userId: The user ID of the auth token to remove, or nil if the auth token type does not apply to a user.
    ///   - completion: A closure to be called when removing of the auth token is complete. The `error` parameter
    ///                 contains any error that prevented the removal of the auth token.
    public func removeAuthToken(forUserId userId: String?, completion: ((_ error: Error?) -> Void)? = nil) {
        store(authToken: nil, forUserId: userId, completion: completion)
    }
}
