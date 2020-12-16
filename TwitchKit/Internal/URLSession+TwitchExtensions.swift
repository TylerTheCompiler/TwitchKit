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
        completion: @escaping (HTTPResponse<AuthorizeWithOAuthAuthCodeResponse, Error>) -> Void
    ) -> URLSessionDataTask {
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
        
        return dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            completion(.init(.init { try self.parse(data: data, response: response, error: error) }, response))
        }
    }
    
    // swiftlint:disable:next function_parameter_count
    internal func authorizeTask(
        clientId: String,
        clientSecret: String,
        authCode: AuthCode,
        redirectURL: URL,
        nonce: String?,
        completion: @escaping (HTTPResponse<AuthorizeWithOIDCAuthCodeResponse, Error>) -> Void
    ) -> URLSessionDataTask {
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
        
        return dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            completion(.init(.init {
                try self.parse(data: data, response: response, error: error, expectedNonce: nonce)
            }, response))
        }
    }
    
    internal func authorizeTask(
        clientId: String,
        clientSecret: String,
        scopes: Set<Scope>,
        completion: @escaping (HTTPResponse<AuthorizeWithClientCredentialsResponse, Error>) -> Void
    ) -> URLSessionDataTask {
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
        
        return dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            completion(.init(.init { try self.parse(data: data, response: response, error: error) }, response))
        }
    }
    
    internal func validationTask<AccessTokenType>(
        with token: AccessTokenType,
        completion: @escaping (HTTPResponse<AccessTokenType.ValidAccessTokenType.Validation, Error>) -> Void
    ) -> URLSessionDataTask where AccessTokenType: AccessToken {
        var request = URLRequest(url: URL(string: "https://id.twitch.tv/oauth2/validate")!)
        // swiftlint:disable:previous force_unwrapping
        request.addValue("OAuth \(token.stringValue)", forHTTPHeaderField: "Authorization")
        
        return dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            completion(.init(.init { try self.parse(data: data, response: response, error: error) }, response))
        }
    }
    
    internal func revokeTask<AccessTokenType>(
        with token: AccessTokenType,
        clientId: String,
        completion: @escaping (HTTPErrorResponse) -> Void
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
            let response = response as? HTTPURLResponse
            let parsedError = self.parseError(data: data, response: response, error: error)
            completion(.init(parsedError, response))
        }
    }
    
    internal func refreshTask(
        with refreshToken: RefreshToken,
        clientId: String,
        clientSecret: String,
        scopes: Set<Scope>,
        completion: @escaping (HTTPResponse<RefreshAccessTokenResponse, Error>) -> Void
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
            let response = response as? HTTPURLResponse
            completion(.init(.init { try self.parse(data: data, response: response, error: error) }, response))
        }
    }
    
    internal func apiTask<Request>(
        with request: Request,
        clientId: String,
        rawAccessToken: String?,
        userId: String?,
        completion: @escaping (HTTPResponse<Request.ResponseBody, Error>) -> Void
    ) -> URLSessionDataTask where Request: APIRequest {
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
           !(requestBody is EmptyCodable),
           let bodyData = try? JSONEncoder.camelCaseToSnakeCase.encode(requestBody) {
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
        
        return dataTask(with: urlRequest) { data, response, error in
            let response = response as? HTTPURLResponse
            completion(.init(.init { try self.parse(data: data, response: response, error: error) }, response))
        }
    }
    
    private func parse<T>(data: Data?,
                          response: HTTPURLResponse?,
                          error: Error?,
                          expectedNonce: String? = nil) throws -> T where T: Decodable {
        if let parsedError = parseError(data: data, response: response, error: error) { throw parsedError }
        
        if T.self == EmptyCodable.self, data.isEmpty {
            // swiftlint:disable:next force_cast
            return EmptyCodable() as! T
        }
        
        do {
            let decoder = JSONDecoder.snakeCaseToCamelCase
            decoder.userInfo[.expectedNonce] = expectedNonce
            return try decoder.decode(T.self, from: data)
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
    
    private func parseError(data: Data?, response: HTTPURLResponse?, error: Error?) -> Error? {
        if let error = error {
            return error
        }
        
        if let apiError = try? JSONDecoder.snakeCaseToCamelCase.decode(APIError.self, from: data) {
            return apiError
        }
        
        if let statusCode = response?.statusCode, !(200..<300).contains(statusCode) {
            return APIError(error: "Bad Response",
                            status: statusCode,
                            message: "Response did not contain a 2XX response code.")
        }
        
        return nil
    }
}
