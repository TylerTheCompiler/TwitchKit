//
//  APISession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// The generic type for Twitch API operations. Used for making API requests to Twitch API endpoints.
///
/// There exist three typealiases for API sessions depending on the type of auth session used.
///
/// API sessions that use a:
/// * `ClientAuthSession` are typealised as `ClientAPISession`.
/// * `ServerUserAuthSession` are typealised as `ServerUserAPISession`.
/// * `ServerAppAuthSession` are typealised as `ServerAppAPISession`.
///
/// API sessions that only need to make unauthorized API requests may be created using the initializer
/// `APISession(clientId:urlSessionConfiguration:)`.
public class APISession<AuthSessionType> where AuthSessionType: AuthSession {
    
    /// The auth session used by the API session.
    public let authSession: AuthSessionType
    
    /// The internal URL session used by the API session.
    internal let urlSession: URLSession
    
    /// Creates a new API session that may only make unauthorized API requests (i.e. requests that do not
    /// require any kind of access token).
    ///
    /// - Parameters:
    ///   - clientId: Your application's client ID.
    ///   - urlSessionConfiguration: The URL session configuration to use, or nil to use the default configuration.
    public init(
        clientId: String,
        urlSessionConfiguration: URLSessionConfiguration? = nil
    ) where AuthSessionType == ClientIdAuthSession {
        self.authSession = .init(clientId: clientId)
        self.urlSession = .init(configuration: urlSessionConfiguration ?? .default)
    }
    
    /// Creates a new API session that can make API requests that require authorization.
    ///
    /// - Parameters:
    ///   - authSession: The auth session to use when making API requests that require authorization.
    ///   - urlSessionConfiguration: The URL session configuration to use, or nil to use the
    ///                              configuration used by `authSession`.
    public init(authSession: AuthSessionType, urlSessionConfiguration: URLSessionConfiguration? = nil) {
        self.authSession = authSession
        
        let effectiveConfig: URLSessionConfiguration
        if let urlSessionConfiguration = urlSessionConfiguration {
            effectiveConfig = urlSessionConfiguration
        } else if let authSession = authSession as? InternalAuthSession {
            effectiveConfig = authSession.urlSessionConfiguration
        } else {
            effectiveConfig = .default
        }
        
        self.urlSession = .init(configuration: effectiveConfig)
    }
    
    // MARK: - Making API Requests
    
    /// Performs an API request that does not require authorization and that returns a response body.
    ///
    /// - Parameters:
    ///   - request: The API request to perform.
    ///   - completion: A closure called when the API request succeeds, or when the request fails or could
    ///                 otherwise not be performed for any reason.
    ///   - response: The response of the API request, containing a result and the `HTTPURLResponse` of the last
    ///               HTTP request made, if any. A successful result contains the API request's `ResponseBody`,
    ///               and an unsuccessful result contains the error that occurred.
    public func perform<Request>(
        _ request: Request,
        completion: @escaping (_ response: Result<(Request.ResponseBody, HTTPURLResponse), Error>) -> Void
    ) where
        Request: APIRequest,
        Request.UserToken == IncompatibleAccessToken,
        Request.AppToken == IncompatibleAccessToken {
        urlSession.apiTask(
            with: request,
            clientId: authSession.clientId,
            rawAccessToken: nil,
            userId: nil,
            completion: completion
        ).resume()
    }
    
    /// Performs an API request that does not require authorization and that does not return a response body.
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
        Request.UserToken == IncompatibleAccessToken,
        Request.AppToken == IncompatibleAccessToken,
        Request.ResponseBody == EmptyCodable {
        urlSession.apiTask(
            with: request,
            clientId: authSession.clientId,
            rawAccessToken: nil,
            userId: nil
        ) { result in
            switch result {
            case .success((_, let response)):
                completion(.success(response))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
}
