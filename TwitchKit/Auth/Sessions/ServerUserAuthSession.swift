//
//  ServerUserAuthSession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/7/20.
//

/// An auth session to be used on your server for authorizing a user through Twitch.
///
/// A `ServerUserAuthSession` authorizes a user by means of an `AuthCode` provided by the client app,
/// transferred to your server by whatever means you choose.
///
/// - Important: Since this auth session requires your client secret, you should NOT use this auth session
///              in any client app - only use this on your server!
public class ServerUserAuthSession: InternalAuthSession {
    
    /// Your application's client ID.
    public let clientId: String
    
    /// Your application's client secret.
    public let clientSecret: String
    
    /// Your application's authorization redirect URL.
    public let redirectURL: URL
    
    /// The set of scopes the auth session requests when authorizing.
    public let scopes: Set<Scope>
    
    /// The ID of the currently-authorized user, or nil if no user has been authorized yet.
    @ReaderWriterValue(wrappedValue: nil, ServerUserAuthSession.self, propertyName: "userId")
    public internal(set) var userId: String?
    
    /// Creates a new server user auth session.
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - clientSecret: Your application's client secret.
    ///   - redirectURL: Your application's authorization redirect URL.
    ///   - scopes: The set of scopes the auth session should authorize with.
    ///   - accessTokenStore: The auth token store to use for the user access token.
    ///   - refreshTokenStore: The auth token store to use for the refresh token.
    ///   - userId: The user ID of the user the new session will be representing, or nil if unknown.
    ///             If nil, `getAccessToken` will return with an error until `getNewAccessToken` is called.
    ///             Default: nil.
    ///   - urlSessionConfiguration: The configuration to use for the internal URL session. Default: `.default`.
    public init<AccessTokenStore, RefreshTokenStore>(
        clientId: String,
        clientSecret: String,
        redirectURL: URL,
        scopes: Set<Scope>,
        accessTokenStore: AccessTokenStore,
        refreshTokenStore: RefreshTokenStore,
        userId: String? = nil,
        urlSessionConfiguration: URLSessionConfiguration = .default
    ) where
        AccessTokenStore: AuthTokenStoring,
        AccessTokenStore.Token == ValidatedUserAccessToken,
        RefreshTokenStore: AuthTokenStoring,
        RefreshTokenStore.Token == RefreshToken {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectURL = redirectURL
        self.scopes = scopes
        self.accessTokenStore = AnyAuthTokenStore(accessTokenStore)
        self.refreshTokenStore = AnyAuthTokenStore(refreshTokenStore)
        self.urlSession = .init(configuration: urlSessionConfiguration)
        self.userId = userId
    }
    
    /// Creates a new server user auth session that uses a `KeychainUserAccessTokenStore` for its access
    /// token store and a `KeychainRefreshTokenStore` for its refresh token store.
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - clientSecret: Your application's client secret.
    ///   - redirectURL: Your application's authorization redirect URL.
    ///   - scopes: The set of scopes the auth session should authorize with.
    ///   - userId: The user ID of the user the new session will be representing, or nil if unknown.
    ///             If nil, `getAccessToken` will return with an error until `getNewAccessToken` is called.
    ///             Default: nil.
    ///   - urlSessionConfiguration: The configuration to use for the internal URL session. Default: `.default`.
    ///   - synchronizesAccessTokensOveriCloud: Whether access tokens should be synchronized over iCloud or not.
    ///                                         Defaults to false.
    public convenience init(
        clientId: String,
        clientSecret: String,
        redirectURL: URL,
        scopes: Set<Scope>,
        userId: String? = nil,
        urlSessionConfiguration: URLSessionConfiguration = .default,
        synchronizesAccessTokensOveriCloud: Bool = false
    ) {
        let accessTokenStore = KeychainUserAccessTokenStore(
            synchronizesOveriCloud: synchronizesAccessTokensOveriCloud,
            identifier: "DefautlServerUserAuthSessionUserAccessTokenStore"
        )
        
        let refreshTokenStore = KeychainRefreshTokenStore(
            identifier: "DefautlServerUserAuthSessionUserAccessTokenStore"
        )
        
        self.init(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURL: redirectURL,
            scopes: scopes,
            accessTokenStore: accessTokenStore,
            refreshTokenStore: refreshTokenStore,
            userId: userId,
            urlSessionConfiguration: urlSessionConfiguration
        )
    }
    
    /// Gets the current access token (if one exists) from the access token store.
    ///
    /// - Parameters:
    ///   - completion: A closure called when fetching the access token completes.
    ///   - result: The result of the fetch containing either the access token or an error.
    public func getCurrentAccessToken(
        completion: @escaping (_ result: Result<ValidatedUserAccessToken, Swift.Error>) -> Void
    ) {
        accessTokenStore.fetchAuthToken(forUserId: userId, completion: completion)
    }
    
    @available(iOS 15.0, macOS 12, *)
    public func currentAccessToken() async throws -> ValidatedUserAccessToken {
        try await accessTokenStore.authToken(forUserId: userId)
    }
    
    /// Returns (via a completion handler) either the current stored user access token after validating it
    /// (or refreshing it if it has become invalid and there is a refresh token in the refresh token store).
    ///
    /// - Parameters:
    ///   - completion: A closure called when a valid user access token is retrieved, or if an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated user access token; un unsuccessful
    ///               result contains the error that occurred.
    public func getAccessToken(
        completion: @escaping (_ response: Result<(ValidatedUserAccessToken, HTTPURLResponse?), Error>) -> Void
    ) {
        accessTokenStore.fetchAuthToken(forUserId: userId) { result in
            switch result {
            case .success(let validatedAccessToken):
                if validatedAccessToken.validation.isRecent {
                    completion(.success((validatedAccessToken, nil)))
                    return
                }
                
                self.validateAndStore(accessToken: validatedAccessToken.unvalidated, refreshToken: nil) { result in
                    switch result {
                    case .success((let validatedAccessToken, let response)):
                        completion(.success((validatedAccessToken, response)))
                        
                    case .failure:
                        self.refreshAccessToken { result in
                            switch result {
                            case .success((let validatedAccessToken, let response)):
                                completion(.success((validatedAccessToken, response)))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
                
            case .failure:
                self.refreshAccessToken { result in
                    switch result {
                    case .success((let validatedAccessToken, let response)):
                        completion(.success((validatedAccessToken, response)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    @available(iOS 15.0, macOS 12, *)
    public func accessToken() async throws -> (ValidatedUserAccessToken, HTTPURLResponse?) {
        do {
            let validatedAccessToken = try await accessTokenStore.authToken(forUserId: userId)
            if validatedAccessToken.validation.isRecent {
                return (validatedAccessToken, nil)
            }
            
            return try await validateAndStore(accessToken: validatedAccessToken.unvalidated, refreshToken: nil)
        } catch {
            return try await refreshAccessToken()
        }
    }
    
    /// Authorizes a user through Twitch via an auth code, and returns (via a completion handler)
    /// a valid user access token.
    ///
    /// - Parameters:
    ///   - authCode: The auth code to authorize with.
    ///   - completion: A closure called when authorization succeeds, or when an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated user access token; an unsuccessdul
    ///               result contains the error that occurred.
    public func getNewAccessToken(
        withAuthCode authCode: AuthCode,
        completion: @escaping (_ response: Result<(ValidatedUserAccessToken, HTTPURLResponse), Error>) -> Void
    ) {
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL
        ) { result in
            switch result {
            case.success((let tokens, _)):
                self.validateAndStore(accessToken: tokens.accessToken,
                                      refreshToken: tokens.refreshToken,
                                      completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    @available(iOS 15, macOS 12, *)
    public func newAccessToken(
        withAuthCode authCode: AuthCode
    ) async throws -> (ValidatedUserAccessToken, HTTPURLResponse) {
        let (tokens, _) = try await urlSession.authorize(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL
        )
        
        return try await validateAndStore(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
    }
    
    /// Authorizes a user through Twitch via an auth code, and returns (via a completion handler)
    /// a valid user access token and an ID token.
    ///
    /// - Parameters:
    ///   - authCode: The auth code to authorize with.
    ///   - expectedNonce: The nonce value expected to match the nonce value of the returned ID token.
    ///                    If the ID token's nonce value does not match this one, this is an indication of a
    ///                    [replay attack](https://en.wikipedia.org/wiki/Replay_attack).
    ///   - completion: A closure called when authorization succeeds, or when an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated user access token; an unsuccessdul
    ///               result contains the error that occurred.
    public func getNewAccessAndIdTokens(
        withAuthCode authCode: AuthCode,
        expectedNonce: String?,
        completion: @escaping (_ response: Result<(ValidatedUserAccessToken, IdToken, HTTPURLResponse), Error>) -> Void
    ) {
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL,
            nonce: expectedNonce
        ) { result in
            switch result {
            case .success((let tokens, _)):
                self.validateAndStore(accessToken: tokens.accessToken,
                                      refreshToken: tokens.refreshToken) { result in
                    switch result {
                    case .success((let validatedAccessToken, let response)):
                        completion(.success((validatedAccessToken, tokens.idToken, response)))
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    @available(iOS 15, macOS 12, *)
    public func newAccessAndIdTokens(
        withAuthCode authCode: AuthCode,
        expectedNonce: String?
    ) async throws -> (ValidatedUserAccessToken, IdToken, HTTPURLResponse) {
        let (tokens, _) = try await urlSession.authorize(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL,
            nonce: expectedNonce
        )
        
        let (validatedAccessToken, resposne) = try await validateAndStore(accessToken: tokens.accessToken,
                                                                          refreshToken: tokens.refreshToken)
        return (validatedAccessToken, tokens.idToken, resposne)
    }
    
    /// Refreshes the current user access token if there is a refresh token in the refresh token store.
    ///
    /// - Parameters:
    ///   - completion: A closure called when refreshing succeeds, or when an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated user access token; an unsuccessdul
    ///               result contains the error that occurred.
    public func refreshAccessToken(
        completion: @escaping (_ response: Result<(ValidatedUserAccessToken, HTTPURLResponse), Error>) -> Void
    ) {
        refreshTokenStore.fetchAuthToken(forUserId: userId) { result in
            switch result {
            case .success(let refreshToken):
                self.urlSession.refreshTask(
                    with: refreshToken,
                    clientId: self.clientId,
                    clientSecret: self.clientSecret,
                    scopes: self.scopes
                ) { result in
                    switch result {
                    case .success((let refreshResponse, _)):
                        self.validateAndStore(accessToken: refreshResponse.accessToken,
                                              refreshToken: refreshResponse.refreshToken,
                                              completion: completion)
                        
                    case .failure(let error):
                        if let error = error as? APIError, (400...401).contains(error.status) {
                            self.refreshTokenStore.removeAuthToken(forUserId: self.userId) { _ in
                                completion(.failure(error))
                            }
                        } else {
                            completion(.failure(error))
                        }
                    }
                }.resume()
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @available(iOS 15, macOS 12, *)
    public func refreshAccessToken() async throws -> (ValidatedUserAccessToken, HTTPURLResponse) {
        let refreshToken = try await refreshTokenStore.authToken(forUserId: userId)
        
        do {
            let (refreshResponse, _) = try await urlSession.refresh(with: refreshToken,
                                                                    clientId: clientId,
                                                                    clientSecret: clientSecret,
                                                                    scopes: scopes)
            return try await validateAndStore(accessToken: refreshResponse.accessToken,
                                              refreshToken: refreshResponse.refreshToken)
        } catch {
            if let error = error as? APIError, (400...401).contains(error.status) {
                try? await self.refreshTokenStore.removeAuthToken(forUserId: self.userId)
            }
            
            throw error
        }
    }
    
    /// Revokes the current user access token if one exists in the access token store.
    ///
    /// - Parameters:
    ///   - completion: A closure called when revoking succeeds, or when an error occurs.
    ///   - response: Contains any error that may have occurred along with an `HTTPURLResponse`
    ///               of the last HTTP request made, if any.
    public func revokeCurrentAccessToken(completion: @escaping (_ response: Result<HTTPURLResponse, Error>) -> Void) {
        accessTokenStore.fetchAuthToken(forUserId: userId) { result in
            switch result {
            case .success(let accessToken):
                self.urlSession.revokeTask(with: accessToken, clientId: self.clientId) { result in
                    switch result {
                    case .success(let response):
                        self.accessTokenStore.removeAuthToken(forUserId: self.userId) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(response))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }.resume()
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @available(iOS 15, macOS 12, *)
    @discardableResult
    public func revokeCurrentAccessToken() async throws -> HTTPURLResponse {
        let accessToken = try await accessTokenStore.authToken(forUserId: userId)
        let response = try await urlSession.revoke(token: accessToken, clientId: clientId)
        try await accessTokenStore.removeAuthToken(forUserId: userId)
        return response
    }
    
    // MARK: - Private
    
    private func validateAndStore(
        accessToken: UserAccessToken,
        refreshToken: RefreshToken?,
        completion: @escaping (Result<(ValidatedUserAccessToken, HTTPURLResponse), Swift.Error>) -> Void
    ) {
        urlSession.validationTask(with: accessToken) { result in
            switch result {
            case .success((let validation, let response)):
                self.userId = validation.userId
                
                let newValidatedAccessToken = ValidatedUserAccessToken(stringValue: accessToken.stringValue,
                                                                       validation: validation)
                self.accessTokenStore.store(
                    authToken: newValidatedAccessToken,
                    forUserId: validation.userId
                ) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        if let refreshToken = refreshToken {
                            self.refreshTokenStore.store(
                                authToken: refreshToken,
                                forUserId: self.userId
                            ) { error in
                                completion(.init {
                                    if let error = error { throw error }
                                    return (newValidatedAccessToken, response)
                                })
                            }
                        } else {
                            completion(.success((newValidatedAccessToken, response)))
                        }
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    @available(iOS 15, macOS 12, *)
    private func validateAndStore(
        accessToken: UserAccessToken,
        refreshToken: RefreshToken?
    ) async throws -> (ValidatedUserAccessToken, HTTPURLResponse) {
        let (validation, response) = try await urlSession.validate(token: accessToken)
        self.userId = validation.userId
        let newValidatedAccessToken = ValidatedUserAccessToken(stringValue: accessToken.stringValue,
                                                               validation: validation)
        try await accessTokenStore.store(authToken: newValidatedAccessToken, forUserId: validation.userId)
        if let refreshToken = refreshToken {
            try await refreshTokenStore.store(authToken: refreshToken, forUserId: validation.userId)
        }
        
        return (newValidatedAccessToken, response)
    }
    
    internal let urlSession: URLSession
    internal var urlSessionConfiguration: URLSessionConfiguration {
        urlSession.configuration
    }
    
    internal let accessTokenStore: AnyAuthTokenStore<ValidatedUserAccessToken>
    internal let refreshTokenStore: AnyAuthTokenStore<RefreshToken>
}
