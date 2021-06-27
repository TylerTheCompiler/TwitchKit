//
//  URLSession+TwitchExtensions.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

internal struct AuthorizeWithOAuthAuthCodeResponse: Decodable {
    internal let accessToken: UserAccessToken
    internal let refreshToken: RefreshToken
}

internal struct AuthorizeWithOIDCAuthCodeResponse: Decodable {
    let accessToken: UserAccessToken
    let refreshToken: RefreshToken
    let idToken: IdToken
}

internal struct AuthorizeWithClientCredentialsResponse: Decodable {
    internal let accessToken: AppAccessToken
}

internal struct RefreshAccessTokenResponse: Decodable {
    let accessToken: UserAccessToken
    let refreshToken: RefreshToken
}

extension URLSession {
    internal func authorizeTask(
        clientId: String,
        clientSecret: String,
        authCode: AuthCode,
        redirectURL: URL,
        completion: @escaping (Result<(AuthorizeWithOAuthAuthCodeResponse, HTTPURLResponse), Error>) -> Void
    ) -> URLSessionDataTask {
        let request = authorizationRequest(clientId: clientId,
                                           clientSecret: clientSecret,
                                           authCode: authCode,
                                           redirectURL: redirectURL)
        
        return dataTask(with: request) { data, response, error in
            completion(.init { try self.parse(data: data, response: response, error: error) })
        }
    }
    
    @available(iOS 15, macOS 12, *)
    internal func authorize(
        clientId: String,
        clientSecret: String,
        authCode: AuthCode,
        redirectURL: URL
    ) async throws -> (AuthorizeWithOAuthAuthCodeResponse, HTTPURLResponse) {
        let request = authorizationRequest(clientId: clientId,
                                           clientSecret: clientSecret,
                                           authCode: authCode,
                                           redirectURL: redirectURL)
        
        let (data, response) = try await self.data(for: request)
        return try self.parse(data: data, response: response, error: nil)
    }
    
    // swiftlint:disable:next function_parameter_count
    internal func authorizeTask(
        clientId: String,
        clientSecret: String,
        authCode: AuthCode,
        redirectURL: URL,
        nonce: String?,
        completion: @escaping (Result<(AuthorizeWithOIDCAuthCodeResponse, HTTPURLResponse), Error>) -> Void
    ) -> URLSessionDataTask {
        let request = authorizationRequest(clientId: clientId,
                                           clientSecret: clientSecret,
                                           authCode: authCode,
                                           redirectURL: redirectURL)
        
        return dataTask(with: request) { data, response, error in
            completion(.init { try self.parse(data: data, response: response, error: error, expectedNonce: nonce) })
        }
    }
    
    @available(iOS 15, macOS 12, *)
    internal func authorize(
        clientId: String,
        clientSecret: String,
        authCode: AuthCode,
        redirectURL: URL,
        nonce: String?
    ) async throws -> (AuthorizeWithOIDCAuthCodeResponse, HTTPURLResponse) {
        let request = authorizationRequest(clientId: clientId,
                                           clientSecret: clientSecret,
                                           authCode: authCode,
                                           redirectURL: redirectURL)
        
        let (data, response) = try await self.data(for: request)
        return try self.parse(data: data, response: response, error: nil, expectedNonce: nonce)
    }
    
    internal func authorizeTask(
        clientId: String,
        clientSecret: String,
        scopes: Set<Scope>,
        completion: @escaping (Result<(AuthorizeWithClientCredentialsResponse, HTTPURLResponse), Error>) -> Void
    ) -> URLSessionDataTask {
        let request = authorizationRequest(clientId: clientId,
                                           clientSecret: clientSecret,
                                           scopes: scopes)
        
        return dataTask(with: request) { data, response, error in
            completion(.init { try self.parse(data: data, response: response, error: error) })
        }
    }
    
    @available(iOS 15, macOS 12, *)
    internal func authorize(
        clientId: String,
        clientSecret: String,
        scopes: Set<Scope>
    ) async throws -> (AuthorizeWithClientCredentialsResponse, HTTPURLResponse) {
        let request = authorizationRequest(clientId: clientId,
                                           clientSecret: clientSecret,
                                           scopes: scopes)
        
        let (data, response) = try await self.data(for: request)
        return try self.parse(data: data, response: response, error: nil)
    }
    
    internal func validationTask<AccessTokenType>(
        with token: AccessTokenType,
        completion: @escaping (Result<(AccessTokenType.ValidAccessTokenType.Validation,
                                       HTTPURLResponse), Error>) -> Void
    ) -> URLSessionDataTask where AccessTokenType: AccessToken {
        var request = URLRequest(url: URL(string: "https://id.twitch.tv/oauth2/validate")!)
        // swiftlint:disable:previous force_unwrapping
        request.addValue("OAuth \(token.stringValue)", forHTTPHeaderField: "Authorization")
        
        return dataTask(with: request) { data, response, error in
            completion(.init { try self.parse(data: data, response: response, error: error) })
        }
    }
    
    @available(iOS 15, macOS 12, *)
    internal func validate<AccessTokenType>(
        token: AccessTokenType
    ) async throws -> (AccessTokenType.ValidAccessTokenType.Validation, HTTPURLResponse)
    where AccessTokenType: AccessToken {
        var request = URLRequest(url: URL(string: "https://id.twitch.tv/oauth2/validate")!)
        // swiftlint:disable:previous force_unwrapping
        request.addValue("OAuth \(token.stringValue)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await self.data(for: request)
        return try self.parse(data: data, response: response, error: nil)
    }
    
    internal func revokeTask<AccessTokenType>(
        with token: AccessTokenType,
        clientId: String,
        completion: @escaping (Result<HTTPURLResponse, Error>) -> Void
    ) -> URLSessionDataTask where AccessTokenType: AccessToken {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "id.twitch.tv"
        components.path = "/oauth2/revoke"
        components.queryItems = [
            .init(name: "client_id", value: clientId),
            .init(name: "token", value: token.stringValue)
        ]
        
        var request = components.urlRequest
        request.httpMethod = "POST"
        
        return dataTask(with: request) { data, response, error in
            do {
                try self.parseError(data: data, response: response, error: error)
                // swiftlint:disable:next force_cast
                completion(.success(response as! HTTPURLResponse))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    @available(iOS 15, macOS 12, *)
    internal func revoke<AccessTokenType>(
        token: AccessTokenType,
        clientId: String
    ) async throws -> HTTPURLResponse where AccessTokenType: AccessToken {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "id.twitch.tv"
        components.path = "/oauth2/revoke"
        components.queryItems = [
            .init(name: "client_id", value: clientId),
            .init(name: "token", value: token.stringValue)
        ]
        
        var request = components.urlRequest
        request.httpMethod = "POST"
        
        let (data, response) = try await self.data(for: request)
        try self.parseError(data: data, response: response, error: nil)
        // swiftlint:disable:next force_cast
        return response as! HTTPURLResponse
    }
    
    internal func refreshTask(
        with refreshToken: RefreshToken,
        clientId: String,
        clientSecret: String,
        scopes: Set<Scope>,
        completion: @escaping (Result<(RefreshAccessTokenResponse, HTTPURLResponse), Error>) -> Void
    ) -> URLSessionDataTask {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "id.twitch.tv"
        components.path = "/oauth2/token"
        components.queryItems = [
            .init(name: "grant_type", value: "refresh_token"),
            .init(name: "refresh_token", value: refreshToken.rawValue),
            .init(name: "client_id", value: clientId),
            .init(name: "client_secret", value: clientSecret)
        ]
        
        if !scopes.isEmpty {
            components.addQueryValue(scopes.map(\.rawValue).joined(separator: " "), for: "scope")
        }
        
        var request = components.urlRequest
        request.httpMethod = "POST"
        
        return dataTask(with: request) { data, response, error in
            completion(.init { try self.parse(data: data, response: response, error: error) })
        }
    }
    
    @available(iOS 15, macOS 12, *)
    internal func refresh(
        with refreshToken: RefreshToken,
        clientId: String,
        clientSecret: String,
        scopes: Set<Scope>
    ) async throws -> (RefreshAccessTokenResponse, HTTPURLResponse) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "id.twitch.tv"
        components.path = "/oauth2/token"
        components.queryItems = [
            .init(name: "grant_type", value: "refresh_token"),
            .init(name: "refresh_token", value: refreshToken.rawValue),
            .init(name: "client_id", value: clientId),
            .init(name: "client_secret", value: clientSecret)
        ]
        
        if !scopes.isEmpty {
            components.addQueryValue(scopes.map(\.rawValue).joined(separator: " "), for: "scope")
        }
        
        var request = components.urlRequest
        request.httpMethod = "POST"
        
        let (data, response) = try await self.data(for: request)
        return try self.parse(data: data, response: response, error: nil)
    }
    
    internal func apiTask<Request>(
        with request: Request,
        clientId: String,
        rawAccessToken: String?,
        userId: String?,
        completion: @escaping (Result<(Request.ResponseBody, HTTPURLResponse), Error>) -> Void
    ) -> URLSessionDataTask? where Request: APIRequest {
        var request = request
        if let userId = userId {
            request.update(with: userId)
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.twitch.tv"
        components.path = "/\(request.apiVersion.rawValue)" + (request.path.hasPrefix("/") ? "" : "/") + request.path
        components.queryItems = request.queryParams.compactMap {
            let name = $0.0
            return $0.1.flatMap { .init(name: name.rawValue, value: $0) }
        }
        
        var urlRequest = components.urlRequest
        urlRequest.httpMethod = request.method.rawValue
        
        if let requestBody = request.body,
           !(requestBody is EmptyCodable) {
            do {
                let bodyData = try JSONEncoder.camelCaseToSnakeCase.encode(requestBody)
                urlRequest.httpBody = bodyData
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(error))
                return nil
            }
        }
        
        if request.apiVersion == .kraken {
            urlRequest.addValue("application/vnd.twitchtv.v5+json", forHTTPHeaderField: "Accept")
        }
        
        urlRequest.addValue(clientId, forHTTPHeaderField: "Client-Id")
        
        if let rawAccessToken = rawAccessToken {
            urlRequest.addValue("\(request.apiVersion.authorizationHeaderPrefix) \(rawAccessToken)",
                                forHTTPHeaderField: "Authorization")
        }
        
        return dataTask(with: urlRequest) { data, response, error in
            completion(.init { try self.parse(data: data, response: response, error: error) })
        }
    }
    
    @available(iOS 15, macOS 12, *)
    internal func callAPI<Request>(
        with request: Request,
        clientId: String,
        rawAccessToken: String?,
        userId: String?
    ) async throws -> (Request.ResponseBody, HTTPURLResponse) where Request: APIRequest {
        var request = request
        if let userId = userId {
            request.update(with: userId)
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.twitch.tv"
        components.path = "/\(request.apiVersion.rawValue)" + (request.path.hasPrefix("/") ? "" : "/") + request.path
        components.queryItems = request.queryParams.compactMap {
            let name = $0.0
            return $0.1.flatMap { .init(name: name.rawValue, value: $0) }
        }
        
        var urlRequest = components.urlRequest
        urlRequest.httpMethod = request.method.rawValue
        
        if let requestBody = request.body,
           !(requestBody is EmptyCodable) {
            let bodyData = try JSONEncoder.camelCaseToSnakeCase.encode(requestBody)
            urlRequest.httpBody = bodyData
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if request.apiVersion == .kraken {
            urlRequest.addValue("application/vnd.twitchtv.v5+json", forHTTPHeaderField: "Accept")
        }
        
        urlRequest.addValue(clientId, forHTTPHeaderField: "Client-Id")
        
        if let rawAccessToken = rawAccessToken {
            urlRequest.addValue("\(request.apiVersion.authorizationHeaderPrefix) \(rawAccessToken)",
                                forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await self.data(for: urlRequest)
        return try self.parse(data: data, response: response, error: nil)
    }
    
    // MARK: - Private
    
    private func authorizationRequest(clientId: String,
                                      clientSecret: String,
                                      authCode: AuthCode,
                                      redirectURL: URL) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "id.twitch.tv"
        components.path = "/oauth2/token"
        components.queryItems = [
            .init(name: "client_id", value: clientId),
            .init(name: "client_secret", value: clientSecret)
        ]
        
        components.addQueryValue(authCode.rawValue, for: "code")
        components.addQueryValue("authorization_code", for: "grant_type")
        components.addQueryValue(redirectURL.absoluteString, for: "redirect_uri")
        
        var request = components.urlRequest
        request.httpMethod = "POST"
        return request
    }
    
    private func authorizationRequest(clientId: String,
                                      clientSecret: String,
                                      scopes: Set<Scope>) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "id.twitch.tv"
        components.path = "/oauth2/token"
        components.queryItems = [
            .init(name: "client_id", value: clientId),
            .init(name: "client_secret", value: clientSecret)
        ]
        
        if !scopes.isEmpty {
            components.addQueryValue(scopes.map(\.rawValue).joined(separator: " "), for: "scope")
        }
        
        components.addQueryValue("client_credentials", for: "grant_type")
        
        var request = components.urlRequest
        request.httpMethod = "POST"
        return request
    }
    
    private func parse<T>(data: Data?,
                          response: URLResponse?,
                          error: Error?,
                          expectedNonce: String? = nil) throws -> (T, HTTPURLResponse) where T: Decodable {
        try parseError(data: data, response: response, error: error)
        
        // swiftlint:disable:next force_cast
        let response = response as! HTTPURLResponse
        
        if T.self == EmptyCodable.self, data.isEmpty {
            // swiftlint:disable:next force_cast
            return (EmptyCodable() as! T, response)
        }
        
        do {
            let decoder = JSONDecoder.snakeCaseToCamelCase
            decoder.userInfo[.expectedNonce] = expectedNonce
            return (try decoder.decode(T.self, from: data), response)
        } catch {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data ?? Data())
                let prettyPrintedJSONData = try JSONSerialization.data(withJSONObject: jsonObject,
                                                                       options: .prettyPrinted)
                let prettyPrintedJSON = String(data: prettyPrintedJSONData, encoding: .utf8) ?? "nil"
                print("Attempted to decode \(String(reflecting: T.self)), but received error:",
                      error, "\nJSON:", prettyPrintedJSON)
            } catch {}
            
            throw error
        }
    }
    
    private func parseError(data: Data?, response: URLResponse?, error: Error?) throws {
        if let error = error { throw error }
        
        if let apiError = try? JSONDecoder.snakeCaseToCamelCase.decode(APIError.self, from: data) {
            throw apiError
        }
        
        if let statusCode = (response as? HTTPURLResponse)?.statusCode, !(200..<300).contains(statusCode) {
            throw APIError(error: "Bad Response",
                           status: statusCode,
                           message: "Response did not contain a 2XX response code.")
        }
    }
}
