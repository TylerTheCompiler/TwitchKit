//
//  AnyAuthTokenStore.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

internal class AnyAuthTokenStore<Token>: AuthTokenStoring where Token: AuthToken {
    internal let baseTokenStore: Any
    
    private let fetchAuthTokenHandler: (String?, @escaping (Result<Token, Error>) -> Void) -> Void
    private let storeAuthTokenHandler: (Token?, String?, ((Error?) -> Void)?) -> Void
    
    internal init<AuthTokenStore>(_ authTokenStore: AuthTokenStore)
    where AuthTokenStore: AuthTokenStoring, AuthTokenStore.Token == Token {
        baseTokenStore = authTokenStore
        self.fetchAuthTokenHandler = authTokenStore.fetchAuthToken
        self.storeAuthTokenHandler = authTokenStore.store
    }
    
    internal func fetchAuthToken(forUserId userId: String?,
                                 completion: @escaping (Result<Token, Error>) -> Void) {
        fetchAuthTokenHandler(userId, completion)
    }
    
    internal func store(authToken: Token?,
                        forUserId userId: String?,
                        completion: ((Error?) -> Void)? = nil) {
        storeAuthTokenHandler(authToken, userId, completion)
    }
}
