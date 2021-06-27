//
//  ClientAPISession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// An API session that uses a client auth session to authorize a user.
///
/// This type of API session may make API requests that require a user access token, as well as
/// requests that do not require any type of access token.
///
/// As this API session requires a client auth session, and thus requires the user to be able to
/// sign in to Twitch via a webview, this type of API session should only be used in a client app.
public typealias ClientAPISession = APISession<ClientAuthSession>

extension APISession where AuthSessionType == ClientAuthSession {
    
    /// A convenience initializer that allows for the creation of a `ClientAPISession` without the
    /// need to create a `ClientAuthSession`.
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - redirectURL: Your application's authorization redirect URL.
    ///   - scopes: The set of scopes the auth session should authorize with.
    ///   - accessTokenStore: The auth token store to use for the user access token.
    ///   - userId: The user ID of the user the new session will be representing, or nil if unknown.
    ///             If this is nil and you attempt to get the current access token (and the access token store
    ///             cannot find a user access token for a nil user ID), the session will prompt the user to
    ///             authorize. Default: nil.
    ///   - defaultAuthFlow: The default auth flow to use when authorizing. This can be changed after
    ///                      instantiating a session. It's recommended to use `.openId`, passing in the claims of
    ///                      your choosing. Default: `.openId(claims: .all)`.
    ///   - prefersEphemeralWebBrowserSession: Whether the internal webview used for authorization should prefer
    ///       to use an ephemeral web browser session or not. Default: false. See:
    ///       [ASWebAuthenticationSession.prefersEphemeralWebBrowserSession][1] for more information.
    ///   - presentationContextProvider: A delegate that provides a display context in which the system can
    ///                                  present an authorization session to the user. This can be changed after
    ///                                  instantiating a session. Default: nil.
    ///   - urlSessionConfiguration: The configuration to use for the internal URL session. Default: `.default`.
    ///
    /// [1]: https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3237231-prefersephemeralwebbrowsersessio
    public convenience init<AccessTokenStore>(
        clientId: String,
        redirectURL: URL,
        scopes: Set<Scope>,
        accessTokenStore: AccessTokenStore,
        userId: String? = nil,
        defaultAuthFlow: ClientAuthSession.AuthFlow = .openId(claims: .all),
        prefersEphemeralWebBrowserSession: Bool = false,
        presentationContextProvider: ClientAuthSessionPresentationContextProviding? = nil,
        urlSessionConfiguration: URLSessionConfiguration = .default
    ) where AccessTokenStore: AuthTokenStoring, AccessTokenStore.Token == ValidatedUserAccessToken {
        let authSession = ClientAuthSession(
            clientId: clientId,
            redirectURL: redirectURL,
            scopes: scopes,
            accessTokenStore: accessTokenStore,
            userId: userId,
            defaultAuthFlow: defaultAuthFlow,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession,
            presentationContextProvider: presentationContextProvider,
            urlSessionConfiguration: urlSessionConfiguration
        )
        
        self.init(authSession: authSession)
    }
    
    /// A convenience initializer that allows for the creation of a `ClientAPISession` without the
    /// need to create a `ClientAuthSession` or an access token store.
    ///
    /// The access token store that is used is a `KeychainUserAccessTokenStore`. The
    /// `synchronizesAccessTokensOveriCloud` parameter can be used to configure whether the the access token
    /// store synchronizes its access tokens over iCloud or not.
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - redirectURL: Your application's authorization redirect URL.
    ///   - scopes: The set of scopes the auth session should authorize with.
    ///   - userId: The user ID of the user the new session will be representing, or nil if unknown.
    ///             If this is nil and you attempt to get the current access token (and the access token store
    ///             cannot find a user access token for a nil user ID), the session will prompt the user to
    ///             authorize. Default: nil.
    ///   - defaultAuthFlow: The default auth flow to use when authorizing. This can be changed after
    ///                      instantiating a session. It's recommended to use `.openId`, passing in the claims of
    ///                      your choosing. Default: `.openId(claims: .all)`.
    ///   - prefersEphemeralWebBrowserSession: Whether the internal webview used for authorization should prefer
    ///       to use an ephemeral web browser session or not. Default: false. See:
    ///       [ASWebAuthenticationSession.prefersEphemeralWebBrowserSession][1] for more information.
    ///   - presentationContextProvider: A delegate that provides a display context in which the system can
    ///                                  present an authorization session to the user. This can be changed after
    ///                                  instantiating a session. Default: nil.
    ///   - urlSessionConfiguration: The configuration to use for the internal URL session. Default: `.default`.
    ///   - synchronizesAccessTokensOveriCloud: Whether access tokens should be synchronized over iCloud or not.
    ///                                         Defaults to false.
    public convenience init(
        clientId: String,
        redirectURL: URL,
        scopes: Set<Scope>,
        userId: String? = nil,
        defaultAuthFlow: ClientAuthSession.AuthFlow = .openId(claims: .all),
        prefersEphemeralWebBrowserSession: Bool = false,
        presentationContextProvider: ClientAuthSessionPresentationContextProviding? = nil,
        urlSessionConfiguration: URLSessionConfiguration = .default,
        synchronizesAccessTokensOveriCloud: Bool = false
    ) {
        let authSession = ClientAuthSession(
            clientId: clientId,
            redirectURL: redirectURL,
            scopes: scopes,
            userId: userId,
            defaultAuthFlow: defaultAuthFlow,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession,
            presentationContextProvider: presentationContextProvider,
            urlSessionConfiguration: urlSessionConfiguration,
            synchronizesAccessTokensOveriCloud: synchronizesAccessTokensOveriCloud
        )
        
        self.init(authSession: authSession)
    }
    
    // MARK: - Making API Requests
    
    /// Performs an API request that requires a user access token and that returns a response body.
    ///
    /// If authorization is needed, the user is prompted to sign in to Twitch with the provided auth flow,
    /// or `authSession`'s default auth flow if the provided auth flow is nil.
    ///
    /// - Parameters:
    ///   - request: The API request to perform.
    ///   - authFlow: The auth flow to use if authorization is needed, or nil to use `authSession`'s
    ///               default auth flow.
    ///   - completion: A closure called when the API request succeeds, or when the request fails or could
    ///                 otherwise not be performed for any reason.
    ///   - response: The response of the API request, containing a result and the `HTTPURLResponse` of the last
    ///               HTTP request made, if any. A successful result contains the API request's `ResponseBody`;
    ///               an unsuccessful result contains the error that occurred.
    public func perform<Request>(
        _ request: Request,
        authFlow: ClientAuthSession.AuthFlow? = nil,
        completion: @escaping (_ response: Result<(Request.ResponseBody, HTTPURLResponse), Error>) -> Void
    ) where
        Request: APIRequest,
        Request.UserToken == ValidatedUserAccessToken {
        getAccessTokenAndPerformRequest(request, authFlow: authFlow, completion: completion)
    }
    
    /// Performs an API request that requires a user access token and that does not return a response body.
    ///
    /// If authorization is needed, the user is prompted to sign in to Twitch with the provided auth flow,
    /// or `authSession`'s default auth flow if the provided auth flow is nil.
    ///
    /// - Parameters:
    ///   - request: The API request to perform.
    ///   - authFlow: The auth flow to use if authorization is needed, or nil to use `authSession`'s
    ///               default auth flow.
    ///   - completion: A closure called when the API request succeeds, or when the request fails or could
    ///                 otherwise not be performed for any reason.
    ///   - response: The response of the API request, containing the error that occurred (if any) and the
    ///               `HTTPURLResponse` of the last HTTP request made, if any.
    public func perform<Request>(
        _ request: Request,
        authFlow: ClientAuthSession.AuthFlow? = nil,
        completion: @escaping (_ response: Result<HTTPURLResponse, Error>) -> Void
    ) where
        Request: APIRequest,
        Request.UserToken == ValidatedUserAccessToken,
        Request.ResponseBody == EmptyCodable {
        getAccessTokenAndPerformRequest(request, authFlow: authFlow) { result in
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
        authFlow: ClientAuthSession.AuthFlow?,
        completion: @escaping (Result<(Request.ResponseBody, HTTPURLResponse), Error>) -> Void
    ) where Request: APIRequest {
        authSession.getAccessToken(reauthorizeUsing: authFlow) { result in
            switch result {
            case .success((let validatedAccessToken, _, _)):
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
                            // Invalid access token, reauthorize and retry:
                            self.authSession.getNewAccessToken(using: authFlow) { result in
                                switch result {
                                case .success((let validatedAccessToken, _, _)):
                                    self.urlSession.apiTask(
                                        with: request,
                                        clientId: self.authSession.clientId,
                                        rawAccessToken: validatedAccessToken.stringValue,
                                        userId: validatedAccessToken.validation.userId,
                                        completion: completion
                                    ).resume()
                                    
                                case .failure(let error):
                                    completion(.failure(error))
                                }
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
}
