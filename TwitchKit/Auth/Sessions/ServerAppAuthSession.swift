//
//  ServerAppAuthSession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/7/20.
//

import Foundation

/// An auth session to be used on your server for authorizing your Twitch application.
///
/// - Important: Since this auth session requires your client secret, you should NOT use this auth session
///              in any client app - only use this on your server!
public class ServerAppAuthSession: InternalAuthSession {
    
    /// Your application's client ID.
    public let clientId: String
    
    /// Your application's client secret.
    public let clientSecret: String
    
    /// The set of scopes the auth session requests when authorizing.
    public let scopes: Set<Scope>
    
    /// Creates a new server app auth session.
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - clientSecret: Your application's client secret.
    ///   - scopes: The set of scopes the auth session should authorize with.
    ///   - accessTokenStore: The auth token store to use for the app access token.
    ///   - urlSessionConfiguration: The configuration to use for the internal URL session. Default: `.default`.
    public init<AuthTokenStore>(
        clientId: String,
        clientSecret: String,
        scopes: Set<Scope>,
        accessTokenStore: AuthTokenStore,
        urlSessionConfiguration: URLSessionConfiguration = .default
    ) where AuthTokenStore: AuthTokenStoring, AuthTokenStore.Token == ValidatedAppAccessToken {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.scopes = scopes
        self.accessTokenStore = AnyAuthTokenStore(accessTokenStore)
        self.urlSession = .init(configuration: urlSessionConfiguration)
    }
    
    /// Creates a new server app auth session that uses a `KeychainAppAccessTokenStore` as its access token store.
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - clientSecret: Your application's client secret.
    ///   - scopes: The set of scopes the auth session should authorize with.
    ///   - urlSessionConfiguration: The configuration to use for the internal URL session. Default: `.default`.
    public convenience init(
        clientId: String,
        clientSecret: String,
        scopes: Set<Scope>,
        urlSessionConfiguration: URLSessionConfiguration = .default
    ) {
        let accessTokenStore = KeychainAppAccessTokenStore(
            identifier: "DefautlServerAppAuthSessionAppAccessTokenStore"
        )
        
        self.init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: accessTokenStore,
            urlSessionConfiguration: urlSessionConfiguration
        )
    }
    
    /// Gets the current access token (if one exists) from the access token store.
    ///
    /// - Parameters:
    ///   - completion: A closure called when fetching the access token completes.
    ///   - result: The result of the fetch containing either the access token or an error.
    public func getCurrentAccessToken(
        completion: @escaping (_ result: Result<ValidatedAppAccessToken, Swift.Error>) -> Void
    ) {
        accessTokenStore.fetchAuthToken(forUserId: nil, completion: completion)
    }
    
    @available(iOS 15, macOS 12, *)
    public func currentAccessToken() async throws -> ValidatedAppAccessToken {
        try await accessTokenStore.authToken(forUserId: nil)
    }
    
    // MARK: - Public
    
    /// Returns (via a completion handler) either the current stored user access token after validating it
    /// (or reauthorizing and getting a new one if it has become invalid).
    ///
    /// - Parameters:
    ///   - completion: A closure called when a valid app access token is retrieved, or if an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated app access token; un unsuccessful
    ///               result contains the error that occurred.
    public func getAccessToken(
        completion: @escaping (_ response: Result<(ValidatedAppAccessToken, HTTPURLResponse?), Error>) -> Void
    ) {
        accessTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success(let validatedAccessToken):
                if validatedAccessToken.validation.isRecent {
                    completion(.success((validatedAccessToken, nil)))
                    return
                }
                
                self.validateAndStore(accessToken: validatedAccessToken.unvalidated) { result in
                    switch result {
                    case .success((let validatedAccessToken, let response)):
                        completion(.success((validatedAccessToken, response)))
                        
                    case .failure:
                        self.getNewAccessToken { result in
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
                self.getNewAccessToken { result in
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
    
    @available(iOS 15, macOS 12, *)
    public func accessToken() async throws -> (ValidatedAppAccessToken, HTTPURLResponse?) {
        do {
            let validatedAccessToken = try await accessTokenStore.authToken(forUserId: nil)
            if validatedAccessToken.validation.isRecent {
                return (validatedAccessToken, nil)
            }
        
            return try await validateAndStore(accessToken: validatedAccessToken.unvalidated)
        } catch {
            return try await newAccessToken()
        }
    }
    
    /// Authorizes the Twitch application through Twitch using the client credentials flow.
    ///
    /// - Parameters:
    ///   - completion: A closure called when authorization succeeds, or when an error occurs.
    ///   - response: Contains the result of the operation and an `HTTPURLResponse` of the last HTTP request
    ///               made, if any. A successful result contains a validated app access token; an unsuccessdul
    ///               result contains the error that occurred.
    public func getNewAccessToken(
        completion: @escaping (_ response: Result<(ValidatedAppAccessToken, HTTPURLResponse), Error>) -> Void
    ) {
        urlSession.authorizeTask(clientId: clientId, clientSecret: clientSecret, scopes: scopes) { result in
            switch result {
            case .success((let accessTokenResponse, _)):
                self.validateAndStore(accessToken: accessTokenResponse.accessToken, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    @available(iOS 15, macOS 12, *)
    public func newAccessToken() async throws -> (ValidatedAppAccessToken, HTTPURLResponse) {
        let (accessTokenResponse, _) = try await urlSession.authorize(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        )
        
        return try await validateAndStore(accessToken: accessTokenResponse.accessToken)
    }
    
    /// Revokes the current app access token if one exists in the access token store.
    ///
    /// - Parameters:
    ///   - completion: A closure called when revoking succeeds, or when an error occurs.
    ///   - response: Contains any error that may have occurred along with an `HTTPURLResponse`
    ///               of the last HTTP request made, if any.
    public func revokeCurrentAccessToken(completion: @escaping (_ response: Result<HTTPURLResponse, Error>) -> Void) {
        accessTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success(let accessToken):
                self.urlSession.revokeTask(with: accessToken, clientId: self.clientId) { result in
                    switch result {
                    case .success(let response):
                        self.accessTokenStore.removeAuthToken(forUserId: nil) { error in
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
        let accessToken = try await accessTokenStore.authToken(forUserId: nil)
        let response = try await urlSession.revoke(token: accessToken, clientId: clientId)
        try await accessTokenStore.removeAuthToken(forUserId: nil)
        return response
    }
    
    // MARK: - Private
    
    private func validateAndStore(
        accessToken: AppAccessToken,
        completion: @escaping (Result<(ValidatedAppAccessToken, HTTPURLResponse), Error>) -> Void
    ) {
        urlSession.validationTask(with: accessToken) { result in
            switch result {
            case .success((let validation, let response)):
                let validatedAccessToken = ValidatedAppAccessToken(stringValue: accessToken.stringValue,
                                                                   validation: validation)
                self.accessTokenStore.store(authToken: validatedAccessToken, forUserId: nil) { error in
                    completion(.init {
                        if let error = error { throw error }
                        return (validatedAccessToken, response)
                    })
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    @available(iOS 15, macOS 12, *)
    private func validateAndStore(accessToken: AppAccessToken) async throws -> (ValidatedAppAccessToken, HTTPURLResponse) {
        let (validation, response) = try await urlSession.validate(token: accessToken)
        let validatedAccessToken = ValidatedAppAccessToken(stringValue: accessToken.stringValue,
                                                           validation: validation)
        try await accessTokenStore.store(authToken: validatedAccessToken, forUserId: nil)
        return (validatedAccessToken, response)
    }
    
    internal let urlSession: URLSession
    internal var urlSessionConfiguration: URLSessionConfiguration {
        urlSession.configuration
    }
    
    internal let accessTokenStore: AnyAuthTokenStore<ValidatedAppAccessToken>
}
