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
    
    /// Returns (via a completion handler) either the current stored user access token after validating it
    /// (or refreshing it if it has become invalid and there is a refresh token in the refresh token store).
    ///
    /// - Parameters:
    ///   - completion: A closure called when a valid user access token is retrieved, or if an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated user access token; un unsuccessful
    ///               result contains the error that occurred.
    public func getAccessToken(
        completion: @escaping (_ response: HTTPResponse<ValidatedUserAccessToken, Error>) -> Void
    ) {
        accessTokenStore.fetchAuthToken(forUserId: userId) { result in
            switch result {
            case .success(let accessToken):
                self.validateAndStore(accessToken: accessToken.unvalidated, refreshToken: nil) { response in
                    switch response.result {
                    case .success(let validatedAccessToken):
                        completion(.init(validatedAccessToken, response.httpURLResponse))
                        
                    case .failure:
                        self.getRefreshedAccessToken(completion: completion)
                    }
                }
                
            case .failure(let error):
                completion(.init(error))
            }
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
        completion: @escaping (_ response: HTTPResponse<ValidatedUserAccessToken, Error>) -> Void
    ) {
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL
        ) { response in
            switch response.result {
            case.success(let tokens):
                self.validateAndStore(accessToken: tokens.accessToken,
                                      refreshToken: tokens.refreshToken,
                                      completion: completion)
                
            case .failure(let error):
                completion(.init(error, response.httpURLResponse))
            }
        }.resume()
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
        completion: @escaping (_ response: HTTPResponse<(ValidatedUserAccessToken, IdToken), Error>) -> Void
    ) {
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL,
            nonce: expectedNonce
        ) { response in
            switch response.result {
            case .success(let tokens):
                self.validateAndStore(accessToken: tokens.accessToken,
                                      refreshToken: tokens.refreshToken) { response in
                    switch response.result {
                    case .success(let validatedAccessToken):
                        completion(.init((validatedAccessToken, tokens.idToken), response.httpURLResponse))
                        
                    case .failure(let error):
                        completion(.init(error, response.httpURLResponse))
                    }
                }
                
            case .failure(let error):
                completion(.init(error, response.httpURLResponse))
            }
        }.resume()
    }
    
    /// Refreshes the current user access token if there is a refresh token in the refresh token store.
    ///
    /// - Parameters:
    ///   - completion: A closure called when refreshing succeeds, or when an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated user access token; an unsuccessdul
    ///               result contains the error that occurred.
    public func getRefreshedAccessToken(
        completion: @escaping (_ response: HTTPResponse<ValidatedUserAccessToken, Error>) -> Void
    ) {
        refreshTokenStore.fetchAuthToken(forUserId: userId) { result in
            switch result {
            case .success(let refreshToken):
                self.urlSession.refreshTask(
                    with: refreshToken,
                    clientId: self.clientId,
                    clientSecret: self.clientSecret,
                    scopes: self.scopes
                ) { response in
                    switch response.result {
                    case .success(let refreshResponse):
                        self.validateAndStore(accessToken: refreshResponse.accessToken,
                                              refreshToken: refreshResponse.refreshToken,
                                              completion: completion)
                        
                    case .failure(let error):
                        if response.httpURLResponse?.statusCode == 401 || response.httpURLResponse?.statusCode == 400 {
                            self.refreshTokenStore.removeAuthToken(forUserId: self.userId) { _ in
                                completion(.init(error, response.httpURLResponse))
                            }
                        } else {
                            completion(.init(error, response.httpURLResponse))
                        }
                    }
                }.resume()
                
            case .failure(let error):
                completion(.init(error))
            }
        }
    }
    
    /// Revokes the current user access token if one exists in the access token store.
    ///
    /// - Parameters:
    ///   - completion: A closure called when revoking succeeds, or when an error occurs.
    ///   - response: Contains any error that may have occurred along with an `HTTPURLResponse`
    ///               of the last HTTP request made, if any.
    public func revokeCurrentAccessToken(completion: @escaping (_ response: HTTPErrorResponse) -> Void) {
        accessTokenStore.fetchAuthToken(forUserId: userId) { result in
            switch result {
            case .success(let accessToken):
                self.urlSession.revokeTask(with: accessToken, clientId: self.clientId) { response in
                    if response.error != nil {
                        completion(response)
                    } else {
                        self.accessTokenStore.removeAuthToken(forUserId: self.userId) { error in
                            completion(.init(error, response.httpURLResponse))
                        }
                    }
                }.resume()
                
            case .failure(let error):
                completion(.init(error))
            }
        }
    }
    
    // MARK: - Private
    
    private func validateAndStore(
        accessToken: UserAccessToken,
        refreshToken: RefreshToken?,
        completion: @escaping (HTTPResponse<ValidatedUserAccessToken, Swift.Error>) -> Void
    ) {
        urlSession.validationTask(with: accessToken) { response in
            switch response.result {
            case .success(let validation):
                self.userId = validation.userId
                
                let newValidatedAccessToken = ValidatedUserAccessToken(stringValue: accessToken.stringValue,
                                                                       validation: validation)
                self.accessTokenStore.store(
                    authToken: newValidatedAccessToken,
                    forUserId: validation.userId
                ) { error in
                    if let error = error {
                        completion(.init(error, response.httpURLResponse))
                    } else {
                        if let refreshToken = refreshToken {
                            self.refreshTokenStore.store(
                                authToken: refreshToken,
                                forUserId: self.userId
                            ) { error in
                                completion(.init(.init {
                                    if let error = error { throw error }
                                    return newValidatedAccessToken
                                }, response.httpURLResponse))
                            }
                        } else {
                            completion(.init(newValidatedAccessToken, response.httpURLResponse))
                        }
                    }
                }
                
            case .failure(let error):
                completion(.init(error, response.httpURLResponse))
            }
        }.resume()
    }
    
    internal let urlSession: URLSession
    internal var urlSessionConfiguration: URLSessionConfiguration {
        urlSession.configuration
    }
    
    private let clientSecret: String
    private let accessTokenStore: AnyAuthTokenStore<ValidatedUserAccessToken>
    private let refreshTokenStore: AnyAuthTokenStore<RefreshToken>
}
