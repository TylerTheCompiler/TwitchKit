//
//  ServerAppAPISession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// An API session that uses a server app auth session to authorize a Twitch application.
///
/// This type of API session may make API requests that require an app access token, as well as
/// requests that do not require any type of access token.
///
/// As this API session requires a server app auth session, and thus requires a client secret,
/// you should only use this type of API session on your server and not in a client app.
public typealias ServerAppAPISession = APISession<ServerAppAuthSession>

extension APISession where AuthSessionType == ServerAppAuthSession {
    
    /// A convenience initializer that allows for the creation of a `ServerAppAPISession` without the
    /// need to create a `ServerAppAuthSession`.
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - clientSecret: Your application's client secret.
    ///   - scopes: The set of scopes the auth session should authorize with.
    ///   - accessTokenStore: The auth token store to use for the app access token.
    ///   - urlSessionConfiguration: The configuration to use for the internal URL session. Default: `.default`.
    public convenience init<AuthTokenStore>(
        clientId: String,
        clientSecret: String,
        scopes: Set<Scope>,
        accessTokenStore: AuthTokenStore,
        urlSessionConfiguration: URLSessionConfiguration = .default
    ) where AuthTokenStore: AuthTokenStoring, AuthTokenStore.Token == ValidatedAppAccessToken {
        let authSession = ServerAppAuthSession(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: accessTokenStore,
            urlSessionConfiguration: urlSessionConfiguration
        )
        
        self.init(authSession: authSession)
    }
    
    /// A convenience initializer that allows for the creation of a `ServerAppAPISession` without the
    /// need to create a `ServerAppAuthSession`.
    ///
    /// The access token store that is used is a `KeychainAppAccessTokenStore`.
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
        let authSession = ServerAppAuthSession(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            urlSessionConfiguration: urlSessionConfiguration
        )
        
        self.init(authSession: authSession)
    }
    
    // MARK: - Making API Requests
    
    /// Performs an API request that requires an app access token and that returns a response body.
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
        completion: @escaping (_ response: HTTPResponse<Request.ResponseBody, Error>) -> Void
    ) where
        Request: APIRequest,
        Request.AppToken == ValidatedAppAccessToken {
        getAccessTokenAndPerformRequest(request, completion: completion)
    }
    
    /// Performs an API request that requires an app access token and that does not return a response body.
    ///
    /// - Parameters:
    ///   - request: The API request to perform.
    ///   - completion: A closure called when the API request succeeds, or when the request fails or could
    ///                 otherwise not be performed for any reason.
    ///   - response: The response of the API request, containing the error that occurred (if any) and the
    ///               `HTTPURLResponse` of the last HTTP request made, if any.
    public func perform<Request>(
        _ request: Request,
        completion: @escaping (_ response: HTTPErrorResponse) -> Void
    ) where
        Request: APIRequest,
        Request.AppToken == ValidatedAppAccessToken,
        Request.ResponseBody == EmptyCodable {
        getAccessTokenAndPerformRequest(request) { response in
            switch response.result {
            case .success:
                completion(.init(nil, response.httpURLResponse))
                
            case .failure(let error):
                completion(.init(error, response.httpURLResponse))
            }
        }
    }
    
    // MARK: - Private
    
    private func getAccessTokenAndPerformRequest<Request>(
        _ request: Request,
        completion: @escaping (HTTPResponse<Request.ResponseBody, Error>) -> Void
    ) where Request: APIRequest {
        authSession.getAccessToken { response in
            switch response.result {
            case .success(let validatedAccessToken):
                self.urlSession.apiTask(
                    with: request,
                    clientId: self.authSession.clientId,
                    rawAccessToken: validatedAccessToken.stringValue,
                    userId: nil,
                    completion: completion
                ).resume()
                
            case .failure(let error):
                completion(.init(error, response.httpURLResponse))
            }
        }
    }
}
