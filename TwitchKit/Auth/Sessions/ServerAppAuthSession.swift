//
//  ServerAppAuthSession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/7/20.
//

/// An auth session to be used on your server for authorizing your Twitch application.
///
/// - Important: Since this auth session requires your client secret, you should NOT use this auth session
///              in any client app - only use this on your server!
public class ServerAppAuthSession: InternalAuthSession {
    
    /// Your application's client ID.
    public let clientId: String
    
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
        completion: @escaping (_ response: HTTPResponse<ValidatedAppAccessToken, Error>) -> Void
    ) {
        accessTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success(let validatedAccessToken):
                if validatedAccessToken.validation.date > Date() - 45 * 60 {
                    completion(.init(validatedAccessToken))
                    return
                }
                
                self.validateAndStore(accessToken: validatedAccessToken.unvalidated) { response in
                    switch response.result {
                    case .success(let validatedAccessToken):
                        completion(.init(validatedAccessToken, response.httpURLResponse))
                        
                    case .failure:
                        self.getNewAccessToken(completion: completion)
                    }
                }
                
            case .failure:
                self.getNewAccessToken(completion: completion)
            }
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
        completion: @escaping (_ response: HTTPResponse<ValidatedAppAccessToken, Error>) -> Void
    ) {
        urlSession.authorizeTask(clientId: clientId, clientSecret: clientSecret, scopes: scopes) { response in
            switch response.result {
            case .success(let accessTokenResponse):
                self.validateAndStore(accessToken: accessTokenResponse.accessToken, completion: completion)
                
            case .failure(let error):
                completion(.init(error, response.httpURLResponse))
            }
        }.resume()
    }
    
    /// Revokes the current app access token if one exists in the access token store.
    ///
    /// - Parameters:
    ///   - completion: A closure called when revoking succeeds, or when an error occurs.
    ///   - response: Contains any error that may have occurred along with an `HTTPURLResponse`
    ///               of the last HTTP request made, if any.
    public func revokeCurrentAccessToken(completion: @escaping (_ response: HTTPErrorResponse) -> Void) {
        accessTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success(let accessToken):
                self.urlSession.revokeTask(with: accessToken, clientId: self.clientId) { response in
                    if response.error != nil {
                        completion(response)
                    } else {
                        self.accessTokenStore.removeAuthToken(forUserId: nil) { error in
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
    
    private func validateAndStore(accessToken: AppAccessToken,
                                  completion: @escaping (HTTPResponse<ValidatedAppAccessToken, Error>) -> Void) {
        urlSession.validationTask(with: accessToken) { response in
            switch response.result {
            case .success(let validation):
                let validatedAccessToken = ValidatedAppAccessToken(stringValue: accessToken.stringValue,
                                                                   validation: validation)
                self.accessTokenStore.store(authToken: validatedAccessToken, forUserId: nil) { error in
                    completion(.init(.init {
                        if let error = error { throw error }
                        return validatedAccessToken
                    }, response.httpURLResponse))
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
    
    internal let clientSecret: String
    
    private let accessTokenStore: AnyAuthTokenStore<ValidatedAppAccessToken>
}
