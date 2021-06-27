//
//  ServerUserAPISession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// An API session that uses a server user auth session to authorize a user.
///
/// This type of API session may make API requests that require a user access token, as well as
/// requests that do not require any type of access token.
///
/// As this API session requires a server user auth session, and thus requires a client secret,
/// you should only use this type of API session on your server and not in a client app.
public typealias ServerUserAPISession = APISession<ServerUserAuthSession>

extension APISession where AuthSessionType == ServerUserAuthSession {
    
    /// A convenience initializer that allows for the creation of a `ServerUserAPISession` without the
    /// need to create a `ServerUserAuthSession`.
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - clientSecret: Your application's client secret.
    ///   - redirectURL: Your application's authorization redirect URL.
    ///   - scopes: The set of scopes the auth session should authorize with.
    ///   - accessTokenStore: The auth token store to use for the user access token.
    ///   - refreshTokenStore: The auth token store to use for the refresh token.
    ///   - userId: The user ID of the user the new session will be representing, or nil if unknown.
    ///             If nil, `authSession.getAccessToken` will return with an error until
    ///             `authSession.getNewAccessToken` is called. Default: nil.
    ///   - urlSessionConfiguration: The configuration to use for the internal URL session. Default: `.default`.
    public convenience init<AccessTokenStore, RefreshTokenStore>(
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
        let authSession = ServerUserAuthSession(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURL: redirectURL,
            scopes: scopes,
            accessTokenStore: accessTokenStore,
            refreshTokenStore: refreshTokenStore,
            userId: userId,
            urlSessionConfiguration: urlSessionConfiguration
        )
        
        self.init(authSession: authSession)
    }
    
    /// A convenience initializer that allows for the creation of a `ServerUserAPISession` without the
    /// need to create a `ServerUserAuthSession`.
    ///
    /// The auth token stores that are used are a `KeychainUserAccessTokenStore` for access tokens and a
    /// `KeychainRefreshTokenStore` for refresh tokens. The `synchronizesAccessTokensOveriCloud` parameter can
    /// be used to configure whether the the access token store synchronizes its access tokens over iCloud or not.
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - clientSecret: Your application's client secret.
    ///   - redirectURL: Your application's authorization redirect URL.
    ///   - scopes: The set of scopes the auth session should authorize with.
    ///   - userId: The user ID of the user the new session will be representing, or nil if unknown.
    ///             If nil, `authSession.getAccessToken` will return with an error until
    ///             `authSession.getNewAccessToken` is called. Default: nil.
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
        let authSession = ServerUserAuthSession(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURL: redirectURL,
            scopes: scopes,
            userId: userId,
            urlSessionConfiguration: urlSessionConfiguration,
            synchronizesAccessTokensOveriCloud: synchronizesAccessTokensOveriCloud
        )
        
        self.init(authSession: authSession)
    }
    
    // MARK: - Making API Requests
    
    /// Performs an API request that requires a user access token and that returns a response body.
    ///
    /// - Parameters:
    ///   - request: The API request to perform.
    ///   - completion: A closure called when the API request succeeds, or when the request fails or could
    ///                 otherwise not be performed for any reason.
    ///   - response: The response of the API request, containing a result and the `HTTPURLResponse` of the last
    ///               HTTP request made, if any. A successful result contains the API request's `ResponseBody`;
    ///               an unsuccessful result contains the error that occurred.
    public func perform<Request>(
        _ request: Request,
        completion: @escaping (_ response: Result<(Request.ResponseBody, HTTPURLResponse), Error>) -> Void
    ) where
        Request: APIRequest,
        Request.UserToken == ValidatedUserAccessToken {
        getAccessTokenAndPerformRequest(request, completion: completion)
    }
    
    /// Performs an API request that requires a user access token and that does not return a response body.
    ///
    /// - Parameters:
    ///   - request: The API request to perform.
    ///   - completion: A closure called when the API request succeeds, or when the request fails or could
    ///                 otherwise not be performed for any reason.
    ///   - response: The response of the API request, containing the error that occurred (if any) and the
    ///               `HTTPURLResponse` of the last HTTP request made, if any.
    public func perform<Request>(
        _ request: Request,
        completion: @escaping (_ response: Result<HTTPURLResponse, Error>) -> Void
    ) where
        Request: APIRequest,
        Request.UserToken == ValidatedUserAccessToken,
        Request.ResponseBody == EmptyCodable {
        getAccessTokenAndPerformRequest(request) { result in
            switch result {
            case .success((_, let response)):
                completion(.success(response))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private
    
    private func getAccessTokenAndPerformRequest<Request>(
        _ request: Request,
        completion: @escaping (Result<(Request.ResponseBody, HTTPURLResponse), Error>) -> Void
    ) where Request: APIRequest {
        authSession.getAccessToken { result in
            switch result {
            case .success((let validatedAccessToken, _)):
                self.urlSession.apiTask(
                    with: request,
                    clientId: self.authSession.clientId,
                    rawAccessToken: validatedAccessToken.stringValue,
                    userId: validatedAccessToken.validation.userId
                ) { result in
                    switch result {
                    case .success((let responseBody, let response)):
                        completion(.success((responseBody, response)))
                        
                    case .failure(let error):
                        if let error = error as? APIError, (400...401).contains(error.status) {
                            self.authSession.refreshAccessToken { result in
                                switch result {
                                case .success((let validatedAccessToken, _)):
                                    self.urlSession.apiTask(
                                        with: request,
                                        clientId: self.authSession.clientId,
                                        rawAccessToken: validatedAccessToken.stringValue,
                                        userId: validatedAccessToken.validation.userId,
                                        completion: completion
                                    )?.resume()
                                    
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        } else {
                            completion(.failure(error))
                        }
                    }
                }?.resume()
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
