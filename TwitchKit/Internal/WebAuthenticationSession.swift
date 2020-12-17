//
//  WebAuthenticationSession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

import AuthenticationServices

/// An interface the Twitch web authentication session uses to ask a delegate for a presentation anchor.
internal protocol WebAuthenticationSessionPresentationContextProviding: AnyObject {
    
    /// Tells the delegate from which window it should present content to the user.
    ///
    /// - Parameter webAuthSession: The session asking for the presentation anchor.
    /// - Returns: The window from which content should be presented to the user.
    func presentationAnchor(for webAuthSession: WebAuthenticationSession) -> PresentationAnchor
}

/// An object used for authenticating a client app with Twitch through a web browser.
internal final class WebAuthenticationSession: NSObject {
    
    /// An error encountered during authentication.
    internal enum Error: Swift.Error {
        
        /// Indicates that the returned callback URL is either nil or an invalid URL upon authentication completion.
        case missingOrInvalidCallbackURL
        
        /// Indicates that the `state` parameter passed into an authentication request does not match
        /// the `state` parameter returned after authentication.
        ///
        /// - Important: This error indicates a possible cross-site request forgery (CSRF) attack!
        case mismatchedState
        
        /// Indicates that no access token was returned in the authentication response.
        case missingAccessToken
        
        /// Indicates that no auth code was returned in the authentication response.
        case missingAuthCode
        
        /// Indicates that no ID token was returned in the authentication response.
        case missingIdToken
    }
    
    /// Describes an authentication flow and its parameters, along with a completion handler to be called when
    /// authentication finishes.
    internal enum Flow {
        
        /// The OAuth Implicit auth flow. Used for obtaining a `UserAccessToken`.
        case accessToken(forceVerify: Bool? = nil,
                         completion: (Result<UserAccessToken, Swift.Error>) -> Void)
        
        /// The OAuth Authorization Code auth flow. Used for obtaining an `AuthCode` to be
        /// sent to your application's server.
        case authCodeUsingOAuth(forceVerify: Bool? = nil,
                                completion: (Result<AuthCode, Swift.Error>) -> Void)
        
        /// The OIDC Implicit auth flow. Used for obtaining an `IdToken`.
        case idToken(claims: Set<Claim> = [],
                     idTokenClaims: Set<Claim> = [],
                     userinfoClaims: Set<Claim> = [],
                     completion: (Result<IdToken, Swift.Error>) -> Void)
        
        /// The OIDC Implicit auth flow. Used for obtaining both an `IdToken` and a `UserAccessToken`.
        case idAndAccessToken(claims: Set<Claim> = [],
                              idTokenClaims: Set<Claim> = [],
                              userinfoClaims: Set<Claim> = [],
                              completion: (Result<(idToken: IdToken,
                                                   accessToken: UserAccessToken), Swift.Error>) -> Void)
        
        /// The OIDC Authorization Code auth flow. Used for obtaining an `AuthCode` to be
        /// sent to your application's server.
        case authCodeUsingOIDC(claims: Set<Claim> = [],
                               idTokenClaims: Set<Claim> = [],
                               userinfoClaims: Set<Claim> = [],
                               completion: (Result<(authCode: AuthCode, nonce: String), Swift.Error>) -> Void)
    }
    
    /// The application client ID for which this session makes authentication requests.
    internal let clientId: String
    
    /// The URL that the internal web browser calls when completing the authentication flow.
    internal let redirectURL: URL
    
    /// The set of scopes with which this session requests authorization.
    internal let scopes: Set<Scope>
    
    /// The type of authentication/authorization flow this session uses.
    internal let flow: Flow
    
    /// Indicates whether the session should ask the browser for a private authentication session.
    ///
    /// Set this to true to request that the browser doesn’t share cookies or other browsing data between the
    /// authentication session and the user’s normal browser session. Whether the request is honored depends on the
    /// user’s default web browser. Safari always honors the request.
    ///
    /// The value of this property is nil by default.
    /// Set this property before you call `start`. Otherwise it has no effect.
    internal var prefersEphemeralWebBrowserSession: Bool?
    
    /// A delegate that provides a display context in which the system can present an
    /// authentication session to the user.
    ///
    /// The presentation context provider provides context to target where in an application's UI the
    /// authorization view should be shown. A provider must be set prior to calling `start`, otherwise the
    /// authorization view cannot be displayed. If deploying to iOS prior to 13.0, the desired window is inferred
    /// by the application's key window.
    internal weak var presentationContextProvider: WebAuthenticationSessionPresentationContextProviding?
    
    /// Whether the session can be successfully started.
    ///
    /// A session can be successfully started if `presentationContextProvider` is not nil and if
    /// there is currently not an auth session in progress.
    internal var canStart: Bool {
        presentationContextProvider != nil && (webAuthSession?.canStart ?? true)
    }
    
    /// Creates a Twitch web authentication session instance.
    ///
    /// - Parameters:
    ///   - clientId: Your client ID.
    ///   - redirectURL: Your registered redirect URL. This must exactly match the redirect URL registered
    ///                  for your application.
    ///   - scopes: A set of scopes that your application requires.
    ///   - prefersEphemeralWebBrowserSession: Whether the session should ask the browser for a private
    ///                                        authentication session. Default: nil.
    ///   - presentationContextProvider: Provides context to target where in an application's UI the
    ///                                  authorization view should be shown. If deploying to iOS prior to 13.0,
    ///                                  the desired window is inferred by the application's key window.
    ///                                  Default: nil.
    ///   - flow: The type of authentication flow this session will use.
    internal init(clientId: String,
                  redirectURL: URL,
                  scopes: Set<Scope>,
                  prefersEphemeralWebBrowserSession: Bool? = nil,
                  presentationContextProvider: WebAuthenticationSessionPresentationContextProviding? = nil,
                  injectable: Injectable = .init(),
                  flow: Flow) {
        self.clientId = clientId
        self.redirectURL = redirectURL
        self.scopes = Set(scopes)
        self.flow = flow
        self.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        self.injectable = injectable
        self.presentationContextProvider = presentationContextProvider
    }
    
    /// Starts an authentication session.
    ///
    /// In macOS, and for iOS apps with a deployment target of iOS 13 or later, after you call `start`, the
    /// session instance stores a strong reference to itself. To avoid deallocation during the authentication
    /// process, the session keeps the reference until after it calls the completion handler.
    ///
    /// For iOS apps with a deployment target earlier than iOS 13, your app must keep a strong reference
    /// to the session to prevent the system from deallocating the session while waiting for authentication
    /// to complete.
    @discardableResult
    internal func start() -> Bool {
        guard canStart else { return false }
        
        let state = injectable.state()
        let components = urlComponents(withState: state)
        let webAuthSession: WebAuthSessionProtocol
        
        switch flow {
        case .accessToken(let forceVerify, let completion):
            guard let session = webAuthSessionForAccessTokenFlow(
                components: components,
                forceVerify: forceVerify,
                state: state,
                completion: completion
            ) else {
                return false
            }
            
            webAuthSession = session
            
        case .idAndAccessToken(let sharedClaims, let idTokenClaims, let userinfoClaims, let completion):
            guard let session = webAuthSessionForIdAndAccessTokenFlow(
                components: components,
                claims: (shared: sharedClaims, idToken: idTokenClaims, userinfo: userinfoClaims),
                state: state,
                completion: completion
            ) else {
                return false
            }
            
            webAuthSession = session
            
        case .idToken(let sharedClaims, let idTokenClaims, let userinfoClaims, let completion):
            guard let session = webAuthSessionForIdTokenFlow(
                components: components,
                claims: (shared: sharedClaims, idToken: idTokenClaims, userinfo: userinfoClaims),
                state: state,
                completion: completion
            ) else {
                return false
            }
            
            webAuthSession = session
        
        case .authCodeUsingOAuth(let forceVerify, let completion):
            guard let session = webAuthSessionForOAuthCodeFlow(
                components: components,
                forceVerify: forceVerify,
                state: state,
                completion: completion
            ) else {
                return false
            }
            
            webAuthSession = session
            
        case .authCodeUsingOIDC(let sharedClaims, let idTokenClaims, let userinfoClaims, let completion):
            guard let session = webAuthSessionForOIDCAuthCodeFlow(
                components: components,
                claims: (shared: sharedClaims, idToken: idTokenClaims, userinfo: userinfoClaims),
                state: state,
                completion: completion
            ) else {
                return false
            }
            
            webAuthSession = session
        }
        
        if presentationContextProvider != nil {
            webAuthSession.presentationContextProvider = self
        } else {
            webAuthSession.presentationContextProvider = nil
        }
        
        if let prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession {
            webAuthSession.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        }
        
        self.webAuthSession = webAuthSession
        
        return webAuthSession.start()
    }
    
    /// Cancels an authentication session.
    ///
    /// If the session has already presented a view with the authentication webpage, calling this method dismisses
    /// that view. Calling cancel() on an already canceled session has no effect.
    internal func cancel() {
        webAuthSession?.cancel()
    }
    
    // MARK: - Internal/Private
    
    // For unit testing
    internal struct Injectable {
        var state = { UUID().uuidString }
        var nonce = { UUID().uuidString }
        var urlComponents = { (urlComponents: URLComponents) in urlComponents }
        var webAuthSession: (URL, String?, @escaping ASWebAuthenticationSession.CompletionHandler) -> WebAuthSessionProtocol = ASWebAuthenticationSession.init
        // swiftlint:disable:previous line_length
    }
    
    internal var injectable: Injectable
    
    @ReaderWriterValue(wrappedValue: nil, WebAuthenticationSession.self, propertyName: "webAuthSession")
    internal var webAuthSession: WebAuthSessionProtocol?
    
    private func urlComponents(withState state: String) -> URLComponents {
        var scopes = self.scopes
        
        switch flow {
        case .accessToken, .authCodeUsingOAuth:
            scopes.remove(.openId)
            
        case .idToken, .idAndAccessToken, .authCodeUsingOIDC:
            scopes.insert(.openId)
        }
        
        let scopeString = scopes.map(\.rawValue).joined(separator: " ")
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "id.twitch.tv"
        components.path = "/oauth2/authorize"
        components.queryItems = [
            .init(name: "client_id", value: clientId),
            .init(name: "redirect_uri", value: redirectURL.absoluteString),
            .init(name: "scope", value: scopeString),
            .init(name: "state", value: state)
        ]
        
        return components
    }
    
    private func webAuthSessionForAccessTokenFlow(
        components: URLComponents,
        forceVerify: Bool?,
        state: String,
        completion: @escaping (Result<UserAccessToken, Swift.Error>) -> Void
    ) -> WebAuthSessionProtocol? {
        var components = components
        components.addQueryValue("token", for: "response_type")
        forceVerify.flatMap { components.addQueryValue($0 ? "true" : "false", for: "force_verify") }
        
        components = injectable.urlComponents(components)
        
        guard let url = components.url else { return nil }
        
        return injectable.webAuthSession(url, redirectURL.scheme) { callback, error in
            self.webAuthSession = nil
            
            completion(.init {
                if let error = error { throw error }
                guard let callback = callback,
                      var callbackComponents = URLComponents(string: callback.absoluteString) else {
                    throw Error.missingOrInvalidCallbackURL
                }
                
                callbackComponents.query = callbackComponents.fragment
                
                guard callbackComponents.firstQueryValue(for: "state") == state else {
                    throw Error.mismatchedState
                }
                
                guard let rawAccessToken = callbackComponents.firstQueryValue(for: "access_token") else {
                    throw Error.missingAccessToken
                }
                
                return UserAccessToken(stringValue: rawAccessToken)
            })
        }
    }
    
    private func webAuthSessionForIdAndAccessTokenFlow(
        components: URLComponents,
        claims: (shared: Set<Claim>, idToken: Set<Claim>, userinfo: Set<Claim>),
        state: String,
        completion: @escaping (Result<(idToken: IdToken, accessToken: UserAccessToken), Swift.Error>) -> Void
    ) -> WebAuthSessionProtocol? {
        var components = components
        let nonce = injectable.nonce()
        components.addQueryValue(nonce, for: "nonce")
        components.addQueryValue("token id_token", for: "response_type")
        add(claims: claims, to: &components)
        
        components = injectable.urlComponents(components)
        
        guard let url = components.url else { return nil }
        
        return injectable.webAuthSession(url, redirectURL.scheme) { callback, error in
            self.webAuthSession = nil
            
            completion(.init {
                if let error = error { throw error }
                guard let callback = callback,
                      var callbackComponents = URLComponents(string: callback.absoluteString) else {
                    throw Error.missingOrInvalidCallbackURL
                }
                
                callbackComponents.query = callbackComponents.fragment
                
                guard callbackComponents.firstQueryValue(for: "state") == state else {
                    throw Error.mismatchedState
                }
                
                guard let rawIdToken = callbackComponents.firstQueryValue(for: "id_token") else {
                    throw Error.missingIdToken
                }
                
                guard let rawAccessToken = callbackComponents.firstQueryValue(for: "access_token") else {
                    throw Error.missingAccessToken
                }
                
                return try (IdToken(stringValue: rawIdToken, expectedNonce: nonce),
                            UserAccessToken(stringValue: rawAccessToken))
            })
        }
    }
    
    private func webAuthSessionForIdTokenFlow(
        components: URLComponents,
        claims: (shared: Set<Claim>, idToken: Set<Claim>, userinfo: Set<Claim>),
        state: String,
        completion: @escaping (Result<IdToken, Swift.Error>) -> Void
    ) -> WebAuthSessionProtocol? {
        var components = components
        let nonce = injectable.nonce()
        components.addQueryValue(nonce, for: "nonce")
        components.addQueryValue("id_token", for: "response_type")
        add(claims: claims, to: &components)
        
        components = injectable.urlComponents(components)
        
        guard let url = components.url else { return nil }
        
        return injectable.webAuthSession(url, redirectURL.scheme) { callback, error in
            self.webAuthSession = nil
            
            completion(.init {
                if let error = error { throw error }
                guard let callback = callback,
                      var callbackComponents = URLComponents(string: callback.absoluteString) else {
                    throw Error.missingOrInvalidCallbackURL
                }
                
                callbackComponents.query = callbackComponents.fragment
                
                guard callbackComponents.firstQueryValue(for: "state") == state else {
                    throw Error.mismatchedState
                }
                
                guard let rawIdToken = callbackComponents.firstQueryValue(for: "id_token") else {
                    throw Error.missingIdToken
                }
                
                return try IdToken(stringValue: rawIdToken, expectedNonce: nonce)
            })
        }
    }
    
    private func webAuthSessionForOAuthCodeFlow(
        components: URLComponents,
        forceVerify: Bool?,
        state: String,
        completion: @escaping (Result<AuthCode, Swift.Error>) -> Void
    ) -> WebAuthSessionProtocol? {
        var components = components
        components.addQueryValue("code", for: "response_type")
        forceVerify.flatMap { components.addQueryValue($0 ? "true" : "false", for: "force_verify") }
        
        components = injectable.urlComponents(components)
        
        guard let url = components.url else { return nil }
        
        return injectable.webAuthSession(url, redirectURL.scheme) { callback, error in
            self.webAuthSession = nil
            
            completion(.init {
                if let error = error { throw error }
                guard let callback = callback,
                      let callbackComponents = URLComponents(string: callback.absoluteString) else {
                    throw Error.missingOrInvalidCallbackURL
                }
                
                guard callbackComponents.firstQueryValue(for: "state") == state else {
                    throw Error.mismatchedState
                }
                
                guard let rawAuthCode = callbackComponents.firstQueryValue(for: "code") else {
                    throw Error.missingAuthCode
                }
                
                return AuthCode(rawValue: rawAuthCode)
            })
        }
    }
    
    private func webAuthSessionForOIDCAuthCodeFlow(
        components: URLComponents,
        claims: (shared: Set<Claim>, idToken: Set<Claim>, userinfo: Set<Claim>),
        state: String,
        completion: @escaping (Result<(authCode: AuthCode, nonce: String), Swift.Error>) -> Void
    ) -> WebAuthSessionProtocol? {
        var components = components
        let nonce = injectable.nonce()
        components.addQueryValue(nonce, for: "nonce")
        components.addQueryValue("code", for: "response_type")
        add(claims: claims, to: &components)
        
        components = injectable.urlComponents(components)
        
        guard let url = components.url else { return nil }
        
        return injectable.webAuthSession(url, redirectURL.scheme) { callback, error in
            self.webAuthSession = nil
            
            completion(.init {
                if let error = error { throw error }
                guard let callback = callback,
                      let callbackComponents = URLComponents(string: callback.absoluteString) else {
                    throw Error.missingOrInvalidCallbackURL
                }
                
                guard callbackComponents.firstQueryValue(for: "state") == state else {
                    throw Error.mismatchedState
                }
                
                guard let rawAuthCode = callbackComponents.firstQueryValue(for: "code") else {
                    throw Error.missingAuthCode
                }
                
                return (AuthCode(rawValue: rawAuthCode), nonce)
            })
        }
    }
    
    private func add(claims: (shared: Set<Claim>, idToken: Set<Claim>, userinfo: Set<Claim>),
                     to components: inout URLComponents) {
        if let claims = Claims(idTokenClaims: claims.idToken.union(claims.shared),
                               userinfoClaims: claims.userinfo.union(claims.shared)),
           let claimsData = try? JSONEncoder.camelCaseToSnakeCase.encode(claims),
           let claimsString = String(data: claimsData, encoding: .utf8) {
            components.addQueryValue(claimsString, for: "claims")
        }
    }
}

extension WebAuthenticationSession: ASWebAuthenticationPresentationContextProviding {
    internal func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // swiftlint:disable:next force_unwrapping
        presentationContextProvider!.presentationAnchor(for: self)
    }
}

// For unit testing
internal protocol WebAuthSessionProtocol: AnyObject {
    var canStart: Bool { get }
    var prefersEphemeralWebBrowserSession: Bool { get set }
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? { get set }
    
    func start() -> Bool
    func cancel()
}

extension ASWebAuthenticationSession: WebAuthSessionProtocol {}
