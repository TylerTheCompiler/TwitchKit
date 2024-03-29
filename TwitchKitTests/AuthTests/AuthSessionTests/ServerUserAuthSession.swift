//
//  ServerUserAuthSessionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/12/20.
//

import XCTest
@testable import TwitchKit

class ServerUserAuthSessionTests: XCTestCase {
    var mockAccessTokenStore: MockAuthTokenStore<ValidatedUserAccessToken>!
    var mockRefreshTokenStore: MockAuthTokenStore<RefreshToken>!
    var serverUserAuthSession: ServerUserAuthSession!
    
    var redirectURLString = "mockscheme://mockhost"
    var clientId = "MockClientId"
    var clientSecret = "MockClientSecret"
    var userId = "MockUserId"
    var userLogin = "MockUserLogin"
    var scopes = Set<Scope>.all
    
    override func setUp() {
        mockAccessTokenStore = .init()
        mockRefreshTokenStore = .init()
    }
    
    override func tearDown() {
        serverUserAuthSession = nil
        mockAccessTokenStore = nil
        mockRefreshTokenStore = nil
    }
    
    func test_givenAccessTokenInAccessTokenStore_getAccessTokenReturnsCurrentAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedAccessTokenString = "MockAccessToken"
        
        let data = Data("""
        {
            "access_token": "\(expectedAccessTokenString)",
            "user_id": "\(userId)",
            "login": "\(userLogin)",
            "client_id": "\(clientId)",
            "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverUserAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            refreshTokenStore: mockRefreshTokenStore,
            userId: userId,
            urlSessionConfiguration: urlSessionConfig
        )
        
        mockAccessTokenStore.tokens[userId] = .init(
            stringValue: expectedAccessTokenString,
            validation: .init(
                userId: userId,
                login: userLogin,
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        serverUserAuthSession.getAccessToken { response in
            switch response.result {
            case .success(let accessToken):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token string")
                XCTAssertEqual(accessToken.validation.clientId, self.clientId, "Incorrect client ID")
                XCTAssertEqual(accessToken.validation.userId, self.userId, "Incorrect user ID")
                XCTAssertEqual(accessToken.validation.login, self.userLogin, "Incorrect user login")
                XCTAssertEqual(accessToken.validation.scopes, self.scopes, "Incorrect scopes")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_getNewAccessToken_returnsNewAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let authCode = AuthCode(rawValue: "MockAuthCode")
        
        let expectedAccessTokenString = "MockAccessToken"
        let expectedRefreshTokenString = "MockRefreshToken"
        
        let data = Data("""
        {
            "access_token": "\(expectedAccessTokenString)",
            "refresh_token": "\(expectedRefreshTokenString)",
            "user_id": "\(userId)",
            "login": "\(userLogin)",
            "client_id": "\(clientId)",
            "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverUserAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            refreshTokenStore: mockRefreshTokenStore,
            userId: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        serverUserAuthSession.getNewAccessToken(withAuthCode: authCode) { response in
            switch response.result {
            case .success(let accessToken):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token string")
                XCTAssertEqual(accessToken.validation.clientId, self.clientId, "Incorrect client ID")
                XCTAssertEqual(accessToken.validation.userId, self.userId, "Incorrect user ID")
                XCTAssertEqual(accessToken.validation.login, self.userLogin, "Incorrect user login")
                XCTAssertEqual(accessToken.validation.scopes, self.scopes, "Incorrect scopes")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_getNewAccessAndIdTokens_returnsNewAccessTokenAndIdToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let authCode = AuthCode(rawValue: "MockAuthCode")

        let expectedAccessTokenString = "MockAccessToken"
        let expectedNonce = UUID().uuidString
        let expectedIdTokenString = generateIdTokenString(nonce: expectedNonce)
        let expectedRefreshTokenString = "MockRefreshToken"

        let data = Data("""
        {
            "access_token": "\(expectedAccessTokenString)",
            "id_token": "\(expectedIdTokenString)",
            "refresh_token": "\(expectedRefreshTokenString)",
            "user_id": "\(userId)",
            "login": "\(userLogin)",
            "client_id": "\(clientId)",
            "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
        }
        """.utf8)

        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }

        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }

        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]

        serverUserAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            refreshTokenStore: mockRefreshTokenStore,
            userId: nil,
            urlSessionConfiguration: urlSessionConfig
        )

        serverUserAuthSession.getNewAccessAndIdTokens(withAuthCode: authCode, expectedNonce: expectedNonce) { response in
            switch response.result {
            case .success((let accessToken, let idToken)):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token string")
                XCTAssertEqual(accessToken.validation.clientId, self.clientId, "Incorrect client ID")
                XCTAssertEqual(accessToken.validation.userId, self.userId, "Incorrect user ID")
                XCTAssertEqual(accessToken.validation.login, self.userLogin, "Incorrect user login")
                XCTAssertEqual(accessToken.validation.scopes, self.scopes, "Incorrect scopes")

                XCTAssertEqual(idToken.stringValue, expectedIdTokenString, "Incorrect ID token")

            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }

            taskToFinish.fulfill()
        }

        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_getRefreshAccessToken_returnsNewAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")

        let expectedAccessTokenString = "MockAccessToken"
        let expectedRefreshTokenString = "MockRefreshToken"

        let data = Data("""
        {
            "access_token": "\(expectedAccessTokenString)",
            "refresh_token": "\(expectedRefreshTokenString)",
            "user_id": "\(userId)",
            "login": "\(userLogin)",
            "client_id": "\(clientId)",
            "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
        }
        """.utf8)

        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }

        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, data)
        }

        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]

        serverUserAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            refreshTokenStore: mockRefreshTokenStore,
            userId: userId,
            urlSessionConfiguration: urlSessionConfig
        )
        
        mockRefreshTokenStore.tokens[userId] = .init(rawValue: expectedRefreshTokenString)

        serverUserAuthSession.getRefreshedAccessToken { response in
            switch response.result {
            case .success(let accessToken):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token string")
                XCTAssertEqual(accessToken.validation.clientId, self.clientId, "Incorrect client ID")
                XCTAssertEqual(accessToken.validation.userId, self.userId, "Incorrect user ID")
                XCTAssertEqual(accessToken.validation.login, self.userLogin, "Incorrect user login")
                XCTAssertEqual(accessToken.validation.scopes, self.scopes, "Incorrect scopes")

            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }

            taskToFinish.fulfill()
        }

        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenInTokenStore_revokeCurrentAccessTokenRevokesAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")

        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }

        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, nil)
        }

        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]

        serverUserAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            refreshTokenStore: mockRefreshTokenStore,
            userId: userId,
            urlSessionConfiguration: urlSessionConfig
        )
        
        mockAccessTokenStore.tokens[userId] = .init(
            stringValue: "MockAccessToken",
            validation: .init(
                userId: userId,
                login: userLogin,
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )

        serverUserAuthSession.revokeCurrentAccessToken { result in
            if let error = result.error {
                XCTFail("Expected to not get error, got: \(error)")
            }

            taskToFinish.fulfill()
        }

        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    // MARK: - Private
    
    private func generateIdTokenString(nonce: String?) -> String {
        let headerDict = [
            "someHeaderKey": "someHeaderValue"
        ]
        
        var payloadDict: [String: Any] = [
            "iss": "issuer",
            "sub": "subject",
            "aud": "audience",
            "exp": 1000,
            "iat": 2000
        ]
        
        payloadDict["nonce"] = nonce
        
        let signature = "someSignature"
        
        let headerData = try! JSONSerialization.data(withJSONObject: headerDict, options: .sortedKeys)
        let payloadData = try! JSONSerialization.data(withJSONObject: payloadDict, options: .sortedKeys)
        
        let header = headerData.base64URLEncodedString
        let payload = payloadData.base64URLEncodedString
        
        return [header, payload, signature].joined(separator: ".")
    }
}
