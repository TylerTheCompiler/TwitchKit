//
//  ClientAuthSession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/7/20.
//

/// An auth session to be used in your client app for authorizing a user through Twitch via a webview.
public class ClientAuthSession: InternalAuthSession {
    
    /// Error type for client auth sessions.
    public enum Error: Swift.Error {
        
        /// An error that occurs when an authorization flow is attempted,
        /// but there is already an authorization flow in progress.
        case operationInProgress
        
        /// An error that occurs when an auth session deallocates before an operation completes.
        case authSessionDeallocated
    }
    
    /// Describes the type of authorization flow that a Client API session may use.
    public enum AuthFlow {
        
        /// The implicit OAuth flow.
        ///
        /// The `forceVerify` parameter specifies whether the user should be re-prompted for
        /// authorization. If this is true, the user is always prompted to confirm authorization. This is useful
        /// to allow your users to switch Twitch accounts, since there is no way to log users out of the API.
        /// Default: false
        case oAuth(forceVerify: Bool = false)
        
        /// The implicit OIDC (OpenID Connect) flow.
        ///
        /// The different claims parameters specify the different [claims][1] to be returned in the
        /// ID token and/or the `UserInfo` endpoint.
        ///
        /// * The first parameter, `claims`, is the set of claims to be returned in
        ///   _both_ the ID token and `UserInfo` endpoint.
        ///
        /// * The second parameter, `idTokenClaims`, is the additional set of claims to be returned
        ///   _only_ in the ID token.
        ///
        /// * The last parameter, `userInfoClaims`, is the additional set of claims to be returned
        ///   _only_ in the `UserInfo` endpoint.
        ///
        /// [1]: https://dev.twitch.tv/docs/authentication/getting-tokens-oidc#claims
        case openId(claims: Set<Claim> = [],
                    idTokenClaims: Set<Claim> = [],
                    userinfoClaims: Set<Claim> = [])
    }
    
    /// Your application's client ID.
    public let clientId: String
    
    /// Your application's authorization redirect URL.
    public let redirectURL: URL
    
    /// The set of scopes the auth session requests when authorizing.
    public let scopes: Set<Scope>
    
    /// The ID of the currently-authorized user, or nil if no user has been authorized yet.
    @ReaderWriterValue(wrappedValue: nil, ClientAuthSession.self, propertyName: "userId")
    public internal(set) var userId: String?
    
    /// The default auth flow to use when authorizing. This can be changed after instantiating a session.
    public var defaultAuthFlow: AuthFlow
    
    /// Whether the internal webview used for authorization should prefer to use an ephemeral web
    /// browser session or not.
    ///
    /// See [ASWebAuthenticationSession.prefersEphemeralWebBrowserSession][1] for more information.
    ///
    /// [1]: https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3237231-prefersephemeralwebbrowsersessio
    public var prefersEphemeralWebBrowserSession: Bool
    
    /// A delegate that provides a display context in which the system can present an authorization
    /// session to the user.
    public weak var presentationContextProvider: ClientAuthSessionPresentationContextProviding?
    
    /// Whether the session is in a state where it can start authorization or not.
    public var canAuthorize: Bool {
        webAuthSession?.canStart ?? true
    }
    
    /// Creates a new client auth session.
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
    public init<AccessTokenStore>(
        clientId: String,
        redirectURL: URL,
        scopes: Set<Scope>,
        accessTokenStore: AccessTokenStore,
        userId: String? = nil,
        defaultAuthFlow: AuthFlow = .openId(claims: .all),
        prefersEphemeralWebBrowserSession: Bool = false,
        presentationContextProvider: ClientAuthSessionPresentationContextProviding? = nil,
        urlSessionConfiguration: URLSessionConfiguration = .default
    ) where AccessTokenStore: AuthTokenStoring, AccessTokenStore.Token == ValidatedUserAccessToken {
        self.clientId = clientId
        self.redirectURL = redirectURL
        self.scopes = scopes
        self.defaultAuthFlow = defaultAuthFlow
        self.accessTokenStore = AnyAuthTokenStore(accessTokenStore)
        self.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        self.presentationContextProvider = presentationContextProvider
        self.urlSession = .init(configuration: urlSessionConfiguration)
        self.userId = userId
    }
    
    /// Creates a new client auth session that uses a `KeychainUserAccessTokenStore` for its access token store.
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
    ///
    /// [1]: https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3237231-prefersephemeralwebbrowsersessio
    public convenience init(
        clientId: String,
        redirectURL: URL,
        scopes: Set<Scope>,
        userId: String? = nil,
        defaultAuthFlow: AuthFlow = .openId(claims: .all),
        prefersEphemeralWebBrowserSession: Bool = false,
        presentationContextProvider: ClientAuthSessionPresentationContextProviding? = nil,
        urlSessionConfiguration: URLSessionConfiguration = .default,
        synchronizesAccessTokensOveriCloud: Bool = false
    ) {
        let accessTokenStore = KeychainUserAccessTokenStore(
            synchronizesOveriCloud: synchronizesAccessTokensOveriCloud,
            identifier: "DefautlClientAuthSessionUserAccessTokenStore"
        )
        
        self.init(
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
    
    /// Returns (via a completion handler) either the current stored user access token after validating it,
    /// or if there is no stored user access token then prompts the user for authorization using the provided
    /// auth flow.
    ///
    /// If reauthorization occurs and the auth flow used is `.openId`, an `IdToken` is also returned in the
    /// result. Otherwise, the `IdToken` in the result is nil.
    ///
    /// - Parameters:
    ///   - authFlow: The auth flow to use if/when reauthorization is needed. If nil, the `defaultAuthFlow` is used.
    ///   - completion: A closure called when a valid user access token is retrieved, or when an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated user access token; un unsuccessful
    ///               result contains the error that occurred.
    public func getAccessToken(
        reauthorizeUsing authFlow: AuthFlow? = nil,
        completion: @escaping (
            _ response: Result<(accessToken: ValidatedUserAccessToken,
                                idToken: IdToken?,
                                response: HTTPURLResponse?), Swift.Error>
        ) -> Void
    ) {
        accessTokenStore.fetchAuthToken(forUserId: userId) { result in
            switch result {
            case .success(let validatedAccessToken):
                if validatedAccessToken.validation.isRecent {
                    completion(.success((validatedAccessToken, nil, nil)))
                    return
                }
                
                self.validateAndStore(validatedAccessToken.unvalidated) { result in
                    switch result {
                    case .success((let newValidatedAccessToken, let response)):
                        completion(.success((newValidatedAccessToken, nil, response)))
                        
                    case .failure:
                        self.getNewAccessToken(using: authFlow) { result in
                            switch result {
                            case .success((let accessToken, let idToken, let response)):
                                completion(.success((accessToken, idToken, response)))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
                
            case .failure:
                self.getNewAccessToken(using: authFlow) { result in
                    switch result {
                    case .success((let accessToken, let idToken, let response)):
                        completion(.success((accessToken, idToken, response)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    /// Prompts the user for authorization using the provided auth flow.
    ///
    /// If the auth session is not in a state to be able to authorize (i.e. if `canAuthorize` returns false),
    /// then the completion handler is called with a failure result and an error of `Error.operationInProgress`.
    ///
    /// If reauthorization occurs and the auth flow used is `.openId`, an `IdToken` is also returned in the
    /// result. Otherwise, the `IdToken` in the result is nil.
    ///
    /// - Parameters:
    ///   - authFlow: The auth flow to use for authorization. If nil, the `defaultAuthFlow` is used.
    ///   - completion: A closure called when authorization succeeds, or when an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated user access token; un unsuccessful
    ///               result contains the error that occurred.
    public func getNewAccessToken(
        using authFlow: AuthFlow? = nil,
        completion: @escaping (
            _ response: Result<(accessToken: ValidatedUserAccessToken,
                                idToken: IdToken?,
                                response: HTTPURLResponse), Swift.Error>
        ) -> Void
    ) {
        guard canAuthorize else {
            completion(.failure(Error.operationInProgress))
            return
        }
        
        webAuthSession = WebAuthenticationSession(
            clientId: clientId,
            redirectURL: redirectURL,
            scopes: scopes,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession,
            presentationContextProvider: self,
            injectable: injectable,
            flow: {
                switch authFlow ?? defaultAuthFlow {
                case .oAuth(let forceVerify):
                    return .accessToken(forceVerify: forceVerify) { [weak self] result in
                        guard let self = self else {
                            completion(.failure(Error.authSessionDeallocated))
                            return
                        }
                        
                        self.webAuthSession = nil
                        
                        switch result {
                        case .success(let accessToken):
                            self.validateAndStore(accessToken) { result in
                                switch result {
                                case .success((let validatedAccessToken, let response)):
                                    completion(.success((validatedAccessToken, nil, response)))
                                    
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                    
                case .openId(let claims, let idTokenClaims, let userInfoClaims):
                    return .idAndAccessToken(
                        claims: claims,
                        idTokenClaims: idTokenClaims,
                        userinfoClaims: userInfoClaims
                    ) { [weak self] result in
                        guard let self = self else {
                            completion(.failure(Error.authSessionDeallocated))
                            return
                        }
                        
                        self.webAuthSession = nil
                        
                        switch result {
                        case .success((let idToken, let accessToken)):
                            self.validateAndStore(accessToken) { result in
                                switch result {
                                case .success((let validatedAccessToken, let response)):
                                    completion(.success((validatedAccessToken, idToken, response)))
                                    
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }()
        )
        
        webAuthSession?.start()
    }
    
    /// Authenticates a user through Twitch with a set of claims, returning an ID token through
    /// a result in a completion handler.
    ///
    /// - Parameters:
    ///   - claims: The set of claims that should be present in _both_ the returned ID token
    ///             and the `UserInfo` endpoint.
    ///   - idTokenClaims: The set of additional claims that should be present _only_ in
    ///                    the returned ID token (and _not_ the `UserInfo` endpoint).
    ///   - userinfoClaims: The set of additional claims that should be present _only_ in
    ///                     the `UserInfo` endpoint (and _not_ the returned ID token).
    ///   - completion: A closure that is called with the authentication results, which is
    ///                 either an ID token or an error.
    ///   - result: The result of the operation. On success, contains an ID token. Otherwise it contains
    ///             the error that occurred.
    public func getIdToken(claims: Set<Claim> = [],
                           idTokenClaims: Set<Claim> = [],
                           userinfoClaims: Set<Claim> = [],
                           completion: @escaping (_ result: Result<IdToken, Swift.Error>) -> Void) {
        guard canAuthorize else {
            completion(.failure(Error.operationInProgress))
            return
        }
        
        webAuthSession = WebAuthenticationSession(
            clientId: clientId,
            redirectURL: redirectURL,
            scopes: scopes,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession,
            presentationContextProvider: self,
            injectable: injectable,
            flow: .idToken(
                claims: claims,
                idTokenClaims: idTokenClaims,
                userinfoClaims: userinfoClaims
            ) { [weak self] result in
                guard let self = self else {
                    completion(.failure(Error.authSessionDeallocated))
                    return
                }
                
                self.webAuthSession = nil
                completion(result)
            }
        )
        
        webAuthSession?.start()
    }
    
    /// Prompts the user to authenticate and returns (via a completion handler) an auth code (and nonce)
    /// to be sent to your server to complete the authorization process.
    ///
    /// - Parameters:
    ///   - authFlow: The auth flow to use for authorization. If nil, the `defaultAuthFlow` is used.
    ///   - completion: A closure called when authentication succeeds, or when an error occurs.
    ///   - result: On success, contains the auth code and nonce that you should send to your server to
    ///             complete the authorization process. On failure, contains the error that occurred.
    public func getAuthCode(
        using authFlow: AuthFlow? = nil,
        completion: @escaping (_ result: Result<(authCode: AuthCode, nonce: String?), Swift.Error>) -> Void
    ) {
        guard canAuthorize else {
            completion(.failure(Error.operationInProgress))
            return
        }
        
        webAuthSession = WebAuthenticationSession(
            clientId: clientId,
            redirectURL: redirectURL,
            scopes: scopes,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession,
            presentationContextProvider: self,
            injectable: injectable,
            flow: {
                switch authFlow ?? defaultAuthFlow {
                case .oAuth(let forceVerify):
                    return .authCodeUsingOAuth(forceVerify: forceVerify) { [weak self] result in
                        guard let self = self else {
                            completion(.failure(Error.authSessionDeallocated))
                            return
                        }
                        
                        self.webAuthSession = nil
                        
                        switch result {
                        case .success(let authCode):
                            completion(.success((authCode, nil)))
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                    
                case .openId(let claims, let idTokenClaims, let userinfoClaims):
                    return .authCodeUsingOIDC(
                        claims: claims,
                        idTokenClaims: idTokenClaims,
                        userinfoClaims: userinfoClaims
                    ) { [weak self] result in
                        guard let self = self else {
                            completion(.failure(Error.authSessionDeallocated))
                            return
                        }
                        
                        self.webAuthSession = nil
                        
                        switch result {
                        case .success((let authCode, let nonce)):
                            completion(.success((authCode, nonce)))
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }()
        )
        
        webAuthSession?.start()
    }
    
    /// Cancels any current auth flow.
    public func cancelAuth() {
        webAuthSession?.cancel()
        webAuthSession = nil
    }
    
    /// Revokes the current user access token if one exists in the access token store.
    ///
    /// - Parameters:
    ///   - completion: A closure called when revoking succeeds, or when an error occurs.
    ///   - response: Contains any error that may have occurred along with an `HTTPURLResponse`
    ///               of the last HTTP request made, if any.
    public func revokeCurrentAccessToken(
        completion: @escaping (_ result: Result<HTTPURLResponse, Swift.Error>) -> Void
    ) {
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
    
    // MARK: - Private
    
    private func validateAndStore(
        _ accessToken: UserAccessToken,
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
                    forUserId: newValidatedAccessToken.validation.userId
                ) { error in
                    completion(.init {
                        if let error = error { throw error }
                        return (newValidatedAccessToken, response)
                    })
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    internal let urlSession: URLSession
    internal var urlSessionConfiguration: URLSessionConfiguration {
        urlSession.configuration
    }
    
    internal let accessTokenStore: AnyAuthTokenStore<ValidatedUserAccessToken>
    
    @ReaderWriterValue(wrappedValue: nil, ClientAuthSession.self, propertyName: "webAuthSession")
    private var webAuthSession: WebAuthenticationSession?
    
    // For unit testing
    internal var injectable: WebAuthenticationSession.Injectable = .init()
}

// MARK: - Async Methods

@available(iOS 15, macOS 12, *)
extension ClientAuthSession {
    
    /// Gets the current access token (if one exists) from the access token store.
    public func currentAccessToken() async throws -> ValidatedUserAccessToken {
        try await accessTokenStore.authToken(forUserId: userId)
    }
    
    /// Returns either the current stored user access token after validating it, or if there is no stored user
    /// access token then prompts the user for authorization using the provided auth flow.
    ///
    /// If reauthorization occurs and the auth flow used is `.openId`, an `IdToken` is also returned. Otherwise,
    /// the `IdToken` is nil.
    ///
    /// - Parameter authFlow: The auth flow to use if/when reauthorization is needed. If nil, the
    ///                       `defaultAuthFlow` is used.
    public func accessToken(
        reauthorizeUsing authFlow: AuthFlow? = nil
    ) async throws -> (accessToken: ValidatedUserAccessToken, idToken: IdToken?, httpURLResponse: HTTPURLResponse?) {
        let validatedAccessToken = try await accessTokenStore.authToken(forUserId: userId)
        if validatedAccessToken.validation.isRecent {
            return (validatedAccessToken, nil, nil)
        }
        
        do {
            let (newValidatedAccessToken, response) = try await validateAndStore(validatedAccessToken.unvalidated)
            return (newValidatedAccessToken, nil, response)
        } catch {
            return try await newAccessToken(using: authFlow)
        }
    }
    
    /// Prompts the user for authorization using the provided auth flow.
    ///
    /// If the auth session is not in a state to be able to authorize (i.e. if `canAuthorize` returns false),
    /// then `Error.operationInProgress` is thrown.
    ///
    /// If reauthorization occurs and the auth flow used is `.openId`, an `IdToken` is also returned. Otherwise,
    /// the `IdToken` is nil.
    ///
    /// - Parameter authFlow: The auth flow to use for authorization. If nil, the `defaultAuthFlow` is used.
    public func newAccessToken(
        using authFlow: AuthFlow? = nil
    ) async throws -> (accessToken: ValidatedUserAccessToken, idToken: IdToken?, httpURLResponse: HTTPURLResponse) {
        guard canAuthorize else {
            throw Error.operationInProgress
        }
        
        return try await withUnsafeThrowingContinuation { continuation in
            webAuthSession = WebAuthenticationSession(
                clientId: clientId,
                redirectURL: redirectURL,
                scopes: scopes,
                prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession,
                presentationContextProvider: self,
                injectable: injectable,
                flow: {
                    switch authFlow ?? defaultAuthFlow {
                    case .oAuth(let forceVerify):
                        return .accessToken(forceVerify: forceVerify) { [weak self] result in
                            guard let self = self else {
                                continuation.resume(throwing: Error.authSessionDeallocated)
                                return
                            }
                            
                            self.webAuthSession = nil
                            
                            switch result {
                            case .success(let accessToken):
                                self.validateAndStore(accessToken) { result in
                                    switch result {
                                    case .success((let validatedAccessToken, let response)):
                                        continuation.resume(returning: (validatedAccessToken, nil, response))
                                        
                                    case .failure(let error):
                                        continuation.resume(throwing: error)
                                    }
                                }
                                
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                        
                    case .openId(let claims, let idTokenClaims, let userInfoClaims):
                        return .idAndAccessToken(
                            claims: claims,
                            idTokenClaims: idTokenClaims,
                            userinfoClaims: userInfoClaims
                        ) { [weak self] result in
                            guard let self = self else {
                                continuation.resume(throwing: Error.authSessionDeallocated)
                                return
                            }
                            
                            self.webAuthSession = nil
                            
                            switch result {
                            case .success((let idToken, let accessToken)):
                                self.validateAndStore(accessToken) { result in
                                    switch result {
                                    case .success((let validatedAccessToken, let response)):
                                        continuation.resume(returning: (validatedAccessToken, idToken, response))
                                        
                                    case .failure(let error):
                                        continuation.resume(throwing: error)
                                    }
                                }
                                
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                }()
            )
            
            webAuthSession?.start()
        }
    }
    
    /// Authenticates a user through Twitch with a set of claims, returning an ID token.
    ///
    /// - Parameters:
    ///   - claims: The set of claims that should be present in _both_ the returned ID token
    ///             and the `UserInfo` endpoint.
    ///   - idTokenClaims: The set of additional claims that should be present _only_ in
    ///                    the returned ID token (and _not_ the `UserInfo` endpoint).
    ///   - userinfoClaims: The set of additional claims that should be present _only_ in
    ///                     the `UserInfo` endpoint (and _not_ the returned ID token).
    public func idToken(claims: Set<Claim> = [],
                        idTokenClaims: Set<Claim> = [],
                        userinfoClaims: Set<Claim> = []) async throws -> IdToken {
        guard canAuthorize else {
            throw Error.operationInProgress
        }
        
        return try await withUnsafeThrowingContinuation { continuation in
            webAuthSession = WebAuthenticationSession(
                clientId: clientId,
                redirectURL: redirectURL,
                scopes: scopes,
                prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession,
                presentationContextProvider: self,
                injectable: injectable,
                flow: .idToken(
                    claims: claims,
                    idTokenClaims: idTokenClaims,
                    userinfoClaims: userinfoClaims
                ) { [weak self] result in
                    guard let self = self else {
                        continuation.resume(throwing: Error.authSessionDeallocated)
                        return
                    }
                    
                    self.webAuthSession = nil
                    continuation.resume(with: result)
                }
            )
            
            webAuthSession?.start()
        }
    }
    
    /// Prompts the user to authenticate and returns an auth code (and nonce) to be sent to your server to
    /// complete the authorization process.
    ///
    /// - Parameter authFlow: The auth flow to use for authorization. If nil, the `defaultAuthFlow` is used.
    public func authCode(using authFlow: AuthFlow? = nil) async throws -> (authCode: AuthCode, nonce: String?) {
        guard canAuthorize else {
            throw Error.operationInProgress
        }
        
        return try await withUnsafeThrowingContinuation { continuation in
            webAuthSession = WebAuthenticationSession(
                clientId: clientId,
                redirectURL: redirectURL,
                scopes: scopes,
                prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession,
                presentationContextProvider: self,
                injectable: injectable,
                flow: {
                    switch authFlow ?? defaultAuthFlow {
                    case .oAuth(let forceVerify):
                        return .authCodeUsingOAuth(forceVerify: forceVerify) { [weak self] result in
                            guard let self = self else {
                                continuation.resume(throwing: Error.authSessionDeallocated)
                                return
                            }
                            
                            self.webAuthSession = nil
                            
                            switch result {
                            case .success(let authCode):
                                continuation.resume(returning: (authCode, nil))
                                
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                        
                    case .openId(let claims, let idTokenClaims, let userinfoClaims):
                        return .authCodeUsingOIDC(
                            claims: claims,
                            idTokenClaims: idTokenClaims,
                            userinfoClaims: userinfoClaims
                        ) { [weak self] result in
                            guard let self = self else {
                                continuation.resume(throwing: Error.authSessionDeallocated)
                                return
                            }
                            
                            self.webAuthSession = nil
                            
                            switch result {
                            case .success((let authCode, let nonce)):
                                continuation.resume(returning: (authCode, nonce))
                                
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                }()
            )
            
            webAuthSession?.start()
        }
    }
    
    /// Revokes the current user access token if one exists in the access token store.
    ///
    /// - Returns: An `HTTPURLResponse` of the last HTTP request made, if any.
    @discardableResult
    public func revokeCurrentAccessToken() async throws -> HTTPURLResponse {
        let accessToken = try await accessTokenStore.authToken(forUserId: userId)
        let response = try await urlSession.revoke(token: accessToken, clientId: clientId)
        try await accessTokenStore.removeAuthToken(forUserId: userId)
        return response
    }
    
    private func validateAndStore(
        _ accessToken: UserAccessToken
    ) async throws -> (accessToken: ValidatedUserAccessToken, httpURLResponse: HTTPURLResponse) {
        let (validation, response) = try await urlSession.validate(token: accessToken)
        self.userId = validation.userId
        
        let newValidatedAccessToken = ValidatedUserAccessToken(stringValue: accessToken.stringValue,
                                                               validation: validation)
        try await accessTokenStore.store(authToken: newValidatedAccessToken,
                                         forUserId: newValidatedAccessToken.validation.userId)
        
        return (newValidatedAccessToken, response)
    }
}

extension ClientAuthSession: WebAuthenticationSessionPresentationContextProviding {
    internal func presentationAnchor(for session: WebAuthenticationSession) -> PresentationAnchor {
        // swiftlint:disable:next force_unwrapping
        presentationContextProvider!.presentationAnchor(for: self)
    }
}
