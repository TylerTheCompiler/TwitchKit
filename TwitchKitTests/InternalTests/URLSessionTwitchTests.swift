//
//  URLSessionTwitchTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

protocol ResponseProviding {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))? { get set }
}

class MockURLProtocol<RequestHandler>: URLProtocol where RequestHandler: ResponseProviding {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    override func startLoading() {
        do {
            let (response, data) = try RequestHandler.requestHandler!(request)
            let effectiveResponse = response ?? HTTPURLResponse(url: request.url!,
                                                                statusCode: 200,
                                                                httpVersion: nil,
                                                                headerFields: nil)!
            
            client?.urlProtocol(self, didReceive: effectiveResponse, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

struct MockAccessToken: AccessToken {
    typealias ValidAccessTokenType = MockValidatedAccessToken
    typealias Validation = MockValidatedAccessToken.Validation
    
    let stringValue: String
}

struct MockValidatedAccessToken: ValidatedAccessToken {
    typealias ValidAccessTokenType = Self
    typealias UnvalidatedAccessTokenType = MockAccessToken
    
    struct Validation: AccessTokenValidation {
        let date: Date
    }
    
    let stringValue: String
    let validation: Validation
    
    var unvalidated: MockAccessToken {
        .init(stringValue: stringValue)
    }
    
    init(stringValue: String, validation: Validation) {
        self.stringValue = stringValue
        self.validation = validation
    }
}

struct MockAPIRequest<ResponseBodyType>: APIRequest where ResponseBodyType: Decodable {
    typealias ResponseBody = ResponseBodyType
    
    struct RequestBody: Encodable {
        let requestValue: String
    }
    
    struct QueryParamKey: RawRepresentable, Equatable, ExpressibleByStringLiteral {
        var rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        init(stringLiteral value: StringLiteralType) {
            self.init(rawValue: value)
        }
    }
    
    var apiVersion: APIVersion
    var method: HTTPMethod
    var path: String
    var queryParams: [(key: QueryParamKey, value: String?)]
    var body: RequestBody?
}

struct MockResponseBody: Decodable {
    let responseValue: String
}

class URLSessionTwitchTests: XCTestCase {
    
    // MARK: - Properties
    
    var urlSession: URLSession!
    
    let userId = "MockUserId"
    let clientId = "MockClientId"
    let clientSecret = "MockClientSecret"
    let redirectURL = URL(string: "mockscheme://mockhost")!
    let scopes = Set<Scope>.all
    let authCode = AuthCode(rawValue: "MockAuthCode")
    let accessToken = "MockAccessToken"
    let refreshToken = "MockRefreshToken"
    var nonce: String!
    
    var idToken: String {
        let headerDict: [String: Any] = [
            "alg": "RS256",
            "typ": "JWT"
        ]
        
        let payloadDict: [String: Any] = [
            "iss": "MockIssuer",
            "sub": "MockSubject",
            "aud": "MockAudience",
            "exp": 1234,
            "iat": 2345,
            "nonce": nonce!,
            "email": "Kappa@Kappa.kappa",
            "email_verified": true,
            "picture": "https://d3aqoihi2n8ty8.cloudfront.net/actions/kappa/dark/animated/1000/4.gif",
            "preferred_username": "Kappa",
            "updated_at": ISO8601DateFormatter.internetDateWithFractionalSecondsFormatter.string(from: Date())
        ]
        
        let header = try! JSONSerialization.data(withJSONObject: headerDict, options: .sortedKeys)
        let payload = try! JSONSerialization.data(withJSONObject: payloadDict, options: .sortedKeys)
        let signature = "MockSignature"
        
        return [
            header.base64URLEncodedString,
            payload.base64URLEncodedString,
            signature
        ].joined(separator: ".")
    }
    
    // MARK: - Setup/Teardown
    
    override func setUp() {
//        let config = URLSessionConfiguration.default
//        config.protocolClasses = [MockURLProtocol.self]
//        urlSession = URLSession(configuration: config)
        nonce = UUID().uuidString
    }
    
    override func tearDown() {
        urlSession = nil
        nonce = nil
    }
    
    // MARK: - Authorization Tests
    
    func test_authorizeWithAuthCode_usingOAuth_succeeds() {
        let authorizationToFinish = expectation(description: "Expected authorization to finish")
        
        let data = Data("""
        {
            "access_token": "\(accessToken)",
            "refresh_token": "\(refreshToken)",
            "expires_in": 3600,
            "scope": [],
            "token_type": "bearer"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL
        ) { response in
            switch response.result {
            case .success(let tokens):
                XCTAssertEqual(tokens.accessToken.stringValue, self.accessToken, "Incorrect access token.")
                XCTAssertEqual(tokens.refreshToken.rawValue, self.refreshToken, "Incorrect refresh token.")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            
            authorizationToFinish.fulfill()
        }.resume()
        
        wait(for: [authorizationToFinish], timeout: 1.0)
    }
    
    func test_authorizeWithAuthCode_usingOAuth_fails() {
        let authorizationToFinish = expectation(description: "Expected authorization to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { _ in
            throw URLError(.init(rawValue: 0))
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL
        ) { response in
            switch response.result {
            case .success:
                XCTFail("Expected authorization to fail")
                
            case .failure:
                break
            }
            
            authorizationToFinish.fulfill()
        }.resume()
        
        wait(for: [authorizationToFinish], timeout: 1.0)
    }
    
    func test_authorizationWithAuthCode_usingOAuth_invalidAccessToken_fails() {
        let authorizationToFinish = expectation(description: "Expected authorization to finish")
        
        let data = Data("""
        {
            "error": "Unauthorized",
            "status": 401,
            "message": "Token invalid or missing required scope"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL
        ) { response in
            switch response.result {
            case .success:
                XCTFail("Expected authorization to fail")
                
            case .failure(let error) where error is APIError:
                break
                
            case .failure(let error):
                XCTFail("Expected APIError error, got: \(error)")
            }
            
            authorizationToFinish.fulfill()
        }.resume()
        
        wait(for: [authorizationToFinish], timeout: 1.0)
    }
    
    func test_authorizeWithAuthCode_usingOIDC_succeeds() throws {
        let authorizationToFinish = expectation(description: "Expected authorization to finish")
        
        let idToken = self.idToken
        let data = Data("""
        {
            "access_token": "\(accessToken)",
            "refresh_token": "\(refreshToken)",
            "id_token": "\(idToken)",
            "expires_in": 3600,
            "scope": [],
            "token_type": "bearer"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL,
            nonce: nonce
        ) { response in
            switch response.result {
            case .success(let tokens):
                XCTAssertEqual(tokens.accessToken.stringValue, self.accessToken, "Incorrect access token.")
                XCTAssertEqual(tokens.refreshToken.rawValue, self.refreshToken, "Incorrect refresh token.")
                XCTAssertEqual(tokens.idToken.stringValue, idToken, "Incorrect ID token.")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            
            authorizationToFinish.fulfill()
        }.resume()
        
        wait(for: [authorizationToFinish], timeout: 1.0)
    }
    
    func test_authorizeWithAuthCode_usingOIDC_fails() throws {
        let authorizationToFinish = expectation(description: "Expected authorization to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { _ in
            throw URLError(.init(rawValue: 0))
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL,
            nonce: nonce
        ) { response in
            switch response.result {
            case .success:
                XCTFail("Expected authorization to fail")
                
            case .failure:
                break
            }
            
            authorizationToFinish.fulfill()
        }.resume()
        
        wait(for: [authorizationToFinish], timeout: 1.0)
    }
    
    func test_authorizationWithAuthCode_usingOIDC_invalidAccessToken_fails() {
        let authorizationToFinish = expectation(description: "Expected authorization to finish")
        
        let data = Data("""
        {
            "error": "Unauthorized",
            "status": 401,
            "message": "Token invalid or missing required scope"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            authCode: authCode,
            redirectURL: redirectURL,
            nonce: nonce
        ) { response in
            switch response.result {
            case .success:
                XCTFail("Expected authorization to fail")
                
            case .failure(let error) where error is APIError:
                break
                
            case .failure(let error):
                XCTFail("Expected APIError error, got: \(error)")
            }
            
            authorizationToFinish.fulfill()
        }.resume()
        
        wait(for: [authorizationToFinish], timeout: 1.0)
    }
    
    func test_authorizeWithClientCredentials_succeeds() {
        let authorizationToFinish = expectation(description: "Expected authorization to finish")
        
        let data = Data("""
        {
            "access_token": "\(accessToken)",
            "refresh_token": "",
            "expires_in": 3600,
            "scope": [],
            "token_type": "bearer"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        ) { response in
            switch response.result {
            case .success(let accessTokenResponse):
                XCTAssertEqual(accessTokenResponse.accessToken.stringValue, self.accessToken,
                               "Incorrect access token.")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            
            authorizationToFinish.fulfill()
        }.resume()
        
        wait(for: [authorizationToFinish], timeout: 1.0)
    }
    
    func test_authorizeWithClientCredentials_fails() {
        let authorizationToFinish = expectation(description: "Expected authorization to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { _ in
            throw URLError(.init(rawValue: 0))
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        ) { response in
            switch response.result {
            case .success:
                XCTFail("Expected authorization to fail")
                
            case .failure:
                break
            }
            
            authorizationToFinish.fulfill()
        }.resume()
        
        wait(for: [authorizationToFinish], timeout: 1.0)
    }
    
    func test_authorizationWithClientCredentials_invalidAccessToken_fails() {
        let authorizationToFinish = expectation(description: "Expected authorization to finish")
        
        let data = Data("""
        {
            "error": "Unauthorized",
            "status": 401,
            "message": "Token invalid or missing required scope"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.authorizeTask(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        ) { response in
            switch response.result {
            case .success:
                XCTFail("Expected authorization to fail")
                
            case .failure(let error) where error is APIError:
                break
                
            case .failure(let error):
                XCTFail("Expected APIError error, got: \(error)")
            }
            
            authorizationToFinish.fulfill()
        }.resume()
        
        wait(for: [authorizationToFinish], timeout: 1.0)
    }
    
    // MARK: - Validating Access Tokens Tests
    
    func test_accessTokenValidation_succeeds() {
        let validationToFinish = expectation(description: "Expected validation to finish")
        let expectedDate = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate)
        
        let data = Data("""
        {
            "date": \(expectedDate.timeIntervalSinceReferenceDate)
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.validationTask(with: MockAccessToken(stringValue: accessToken)) { response in
            switch response.result {
            case .success(let validation):
                XCTAssertEqual(validation.date.timeIntervalSinceReferenceDate,
                               expectedDate.timeIntervalSinceReferenceDate,
                               "Incorrect validation date.")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            
            validationToFinish.fulfill()
        }.resume()
        
        wait(for: [validationToFinish], timeout: 1.0)
    }
    
    func test_accessTokenValidation_fails() {
        let validationToFinish = expectation(description: "Expected validation to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { _ in
            throw URLError(.init(rawValue: 0))
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.validationTask(with: MockAccessToken(stringValue: accessToken)) { response in
            switch response.result {
            case .success:
                XCTFail("Expected validation to fail")
                
            case .failure:
                break
            }
            
            validationToFinish.fulfill()
        }.resume()
        
        wait(for: [validationToFinish], timeout: 1.0)
    }
    
    func test_invalidAccessTokenValidation_fails() {
        let validationToFinish = expectation(description: "Expected validation to finish")
        
        let data = Data("""
        {
            "error": "Unauthorized",
            "status": 401,
            "message": "Token invalid or missing required scope"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.validationTask(with: MockAccessToken(stringValue: accessToken)) { response in
            switch response.result {
            case .success:
                XCTFail("Expected validation to fail")
                
            case .failure(let error) where error is APIError:
                break
                
            case .failure(let error):
                XCTFail("Expected APIError error, got: \(error)")
            }
            
            validationToFinish.fulfill()
        }.resume()
        
        wait(for: [validationToFinish], timeout: 1.0)
    }
    
    // MARK: - Revoking Access Tokens Tests
    
    func test_revoking_succeeds() {
        let revokingToFinish = expectation(description: "Expected revoking to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, nil)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.revokeTask(
            with: MockAccessToken(stringValue: accessToken),
            clientId: clientId
        ) { response in
            XCTAssertNil(response.error, "Expected no error")
            revokingToFinish.fulfill()
        }.resume()
        
        wait(for: [revokingToFinish], timeout: 1.0)
    }
    
    func test_revoking_fails() {
        let revokingToFinish = expectation(description: "Expected revoking to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { _ in
            throw URLError(.init(rawValue: 0))
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.revokeTask(
            with: MockAccessToken(stringValue: accessToken),
            clientId: clientId
        ) { response in
            XCTAssertNotNil(response.error, "Expected error")
            revokingToFinish.fulfill()
        }.resume()
        
        wait(for: [revokingToFinish], timeout: 1.0)
    }
    
    func test_revoking_failsWithAPIError() {
        let revokingToFinish = expectation(description: "Expected revoking to finish")
        
        let data = Data("""
        {
            "error": "Unauthorized",
            "status": 401,
            "message": "This is an APIError",
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.revokeTask(
            with: MockAccessToken(stringValue: accessToken),
            clientId: clientId
        ) { response in
            XCTAssertNotNil(response.error, "Expected error")
            revokingToFinish.fulfill()
        }.resume()
        
        wait(for: [revokingToFinish], timeout: 1.0)
    }
    
    // MARK: - Refreshing Access Tokens Tests
    
    func test_refreshing_succeeds() {
        let refreshingToFinish = expectation(description: "Expected refreshing to finish")
        
        let data = Data("""
        {
            "access_token": "\(accessToken)",
            "refresh_token": "\(refreshToken)",
            "scope": ""
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.refreshTask(
            with: RefreshToken(rawValue: refreshToken),
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        ) { response in
            switch response.result {
            case .success(let refreshResponse):
                XCTAssertEqual(refreshResponse.accessToken.stringValue, self.accessToken,
                               "Incorrect access token value.")
                XCTAssertEqual(refreshResponse.refreshToken.rawValue, self.refreshToken,
                               "Incorrect refresh token value.")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            
            refreshingToFinish.fulfill()
        }.resume()
        
        wait(for: [refreshingToFinish], timeout: 1.0)
    }
    
    func test_refreshing_fails() {
        let refreshingToFinish = expectation(description: "Expected refreshing to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { _ in
            throw URLError(.init(rawValue: 0))
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.refreshTask(
            with: RefreshToken(rawValue: refreshToken),
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        ) { response in
            switch response.result {
            case .success:
                XCTFail("Expected refreshing to fail")
                
            case .failure:
                break
            }
            
            refreshingToFinish.fulfill()
        }.resume()
        
        wait(for: [refreshingToFinish], timeout: 1.0)
    }
    
    func test_refreshing_failsWithAPIError() {
        let refreshingToFinish = expectation(description: "Expected refreshing to finish")
        
        let data = Data("""
        {
            "error": "Unauthorized",
            "status": 401,
            "message": "This is an APIError"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.refreshTask(
            with: RefreshToken(rawValue: refreshToken),
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        ) { response in
            switch response.result {
            case .success:
                XCTFail("Expected refreshing to fail")
                
            case .failure:
                break
            }
            
            refreshingToFinish.fulfill()
        }.resume()
        
        wait(for: [refreshingToFinish], timeout: 1.0)
    }
    
    // MARK: - API Task Tests
    
    func test_helixAPITask_succeeds() {
        let apiTaskToFinish = expectation(description: "Expected API task to finish")
        let expectedResponseValue = "MockResponseValue"
        
        let data = Data("""
        {
            "response_value": "\(expectedResponseValue)"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "api.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.apiTask(
            with: MockAPIRequest<MockResponseBody>(
                apiVersion: .helix,
                method: .post,
                path: "/some/path",
                queryParams: [("key", "value")],
                body: .init(requestValue: "requestValue")
            ),
            clientId: clientId,
            rawAccessToken: accessToken,
            userId: userId
        ) { response in
            switch response.result {
            case .success(let responseBody):
                XCTAssertEqual(responseBody.responseValue, expectedResponseValue,
                               "Expected response value to be equal to expected value")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            
            apiTaskToFinish.fulfill()
        }.resume()
        
        wait(for: [apiTaskToFinish], timeout: 1.0)
    }
    
    func test_krakenAPITask_succeeds() {
        let apiTaskToFinish = expectation(description: "Expected API task to finish")
        let expectedResponseValue = "MockResponseValue"
        
        let data = Data("""
        {
            "response_value": "\(expectedResponseValue)"
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "api.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.apiTask(
            with: MockAPIRequest<MockResponseBody>(
                apiVersion: .kraken,
                method: .post,
                path: "some/path",
                queryParams: [("key", "value")],
                body: .init(requestValue: "requestValue")
            ),
            clientId: clientId,
            rawAccessToken: accessToken,
            userId: userId
        ) { response in
            switch response.result {
            case .success(let responseBody):
                XCTAssertEqual(responseBody.responseValue, expectedResponseValue,
                               "Expected response value to be equal to expected value")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            
            apiTaskToFinish.fulfill()
        }.resume()
        
        wait(for: [apiTaskToFinish], timeout: 1.0)
    }
    
    func test_apiTaskForEmptyResponse_succeeds() {
        let apiTaskToFinish = expectation(description: "Expected API task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "api.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, Data())
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.apiTask(
            with: MockAPIRequest<EmptyCodable>(
                apiVersion: .helix,
                method: .post,
                path: "/some/path",
                queryParams: [("key", "value")],
                body: .init(requestValue: "requestValue")
            ),
            clientId: clientId,
            rawAccessToken: accessToken,
            userId: userId
        ) { response in
            switch response.result {
            case .success(let emptyCodable):
                XCTAssertEqual(emptyCodable, EmptyCodable(),
                               "Expected response body to be an empty codable")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            
            apiTaskToFinish.fulfill()
        }.resume()
        
        wait(for: [apiTaskToFinish], timeout: 1.0)
    }
    
    func test_apiTask_failsDueToBadResponseCode() {
        let apiTaskToFinish = expectation(description: "Expected API task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "api.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!, nil)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        urlSession = URLSession(configuration: config)
        
        urlSession.apiTask(
            with: MockAPIRequest<MockResponseBody>(
                apiVersion: .helix,
                method: .post,
                path: "/some/path",
                queryParams: [("key", "value")],
                body: .init(requestValue: "requestValue")
            ),
            clientId: clientId,
            rawAccessToken: accessToken,
            userId: userId
        ) { response in
            switch response.result {
            case .success:
                XCTFail("Expected API request to fail")
                
            case .failure(let error) where error is APIError:
                let error = error as! APIError
                let expectedError = APIError(error: "Bad Response",
                                             status: error.status,
                                             message: "Response did not contain a 2XX response code.")
                XCTAssertEqual(error, expectedError,
                               "Expected error to be equal to expected APIError")
                
            case .failure(let error):
                XCTFail("Expected APIError error, got: \(error)")
            }
            
            apiTaskToFinish.fulfill()
        }.resume()
        
        wait(for: [apiTaskToFinish], timeout: 1.0)
    }
}
