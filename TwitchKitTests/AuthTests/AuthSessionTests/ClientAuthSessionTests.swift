//
//  ClientAuthSessionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/12/20.
//

import XCTest
@testable import TwitchKit

class ClientAuthSessionTests: XCTestCase {
    var mockAccessTokenStore: MockAuthTokenStore<ValidatedUserAccessToken>!
    var clientAuthSession: ClientAuthSession!
    
    var redirectURLString = "mockscheme://mockhost"
    var clientId = "MockClientId"
    var userId = "MockUserId"
    var userLogin = "MockUserLogin"
    var scopes = Set<Scope>.all
    
    override func setUp() {
        mockAccessTokenStore = .init()
    }
    
    override func tearDown() {
        clientAuthSession = nil
        mockAccessTokenStore = nil
    }
    
    func test_givenOIDCAuthFlow_getNewAccessToken_returnsNewAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedNonce = UUID().uuidString
        let expectedIdToken = generateIdTokenString(nonce: expectedNonce)
        let expectedAccessTokenString = "MockAccessToken"
        let state = UUID().uuidString
        
        let data = Data("""
        {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.nonce = { expectedNonce }
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)#id_token=\(expectedIdToken)&access_token=\(expectedAccessTokenString)&state=\(state)")
            return session
        }
        
        clientAuthSession.getNewAccessToken { response in
            switch response.result {
            case .success((let accessToken, let idToken)):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token string")
                XCTAssertEqual(accessToken.validation.clientId, self.clientId, "Incorrect client ID")
                XCTAssertEqual(accessToken.validation.userId, self.userId, "Incorrect user ID")
                XCTAssertEqual(accessToken.validation.login, self.userLogin, "Incorrect user login")
                XCTAssertEqual(accessToken.validation.scopes, self.scopes, "Incorrect scopes")
                
                XCTAssertEqual(idToken?.rawValue, expectedIdToken, "Incorrect ID token raw value")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenOAuthAuthFlow_getNewAccessToken_returnsNewAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedAccessTokenString = "MockAccessToken"
        let state = UUID().uuidString
        
        let data = Data("""
        {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .oAuth(forceVerify: false),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)#access_token=\(expectedAccessTokenString)&state=\(state)")
            return session
        }
        
        clientAuthSession.getNewAccessToken { response in
            switch response.result {
            case .success((let accessToken, let idToken)):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token string")
                XCTAssertEqual(accessToken.validation.clientId, self.clientId, "Incorrect client ID")
                XCTAssertEqual(accessToken.validation.userId, self.userId, "Incorrect user ID")
                XCTAssertEqual(accessToken.validation.login, self.userLogin, "Incorrect user login")
                XCTAssertEqual(accessToken.validation.scopes, self.scopes, "Incorrect scopes")
                
                XCTAssertNil(idToken, "Expected ID token to be nil")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_getIdToken_returnsNewIdToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedNonce = UUID().uuidString
        let expectedIdToken = generateIdTokenString(nonce: expectedNonce)
        let state = UUID().uuidString
        
        let urlSessionConfig = URLSessionConfiguration.default
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.nonce = { expectedNonce }
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)#id_token=\(expectedIdToken)&state=\(state)")
            return session
        }
        
        clientAuthSession.getIdToken { result in
            switch result {
            case .success(let idToken):
                XCTAssertEqual(idToken.rawValue, expectedIdToken, "Incorrect ID token string")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenOIDCAuthFlow_getAuthCode_returnsNewAuthCode() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedNonce = UUID().uuidString
        let expectedAuthCode = "MockAuthCode"
        let state = UUID().uuidString
        
        let urlSessionConfig = URLSessionConfiguration.default
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.nonce = { expectedNonce }
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)?code=\(expectedAuthCode)&state=\(state)")
            return session
        }
        
        clientAuthSession.getAuthCode { response in
            switch response {
            case .success((let authCode, let nonce)):
                XCTAssertEqual(authCode.rawValue, expectedAuthCode, "Incorrect auth code string")
                XCTAssertEqual(nonce, expectedNonce, "Incorrect nonce")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenOAuthAuthFlow_getAuthCode_returnsNewAuthCode() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedAuthCode = "MockAuthCode"
        let state = UUID().uuidString
        
        let urlSessionConfig = URLSessionConfiguration.default
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .oAuth(forceVerify: false),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)?code=\(expectedAuthCode)&state=\(state)")
            return session
        }
        
        clientAuthSession.getAuthCode { response in
            switch response {
            case .success((let authCode, let nonce)):
                XCTAssertEqual(authCode.rawValue, expectedAuthCode, "Incorrect auth code string")
                XCTAssertNil(nonce, "Expected nonce to be nil")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenExistsInTokenStore_andHasRecentValidation_getAccessTokenReturnsCurrentAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        let expectedAccessTokenString = "MockAccessToken"
        
        let expectedAccessToken = ValidatedUserAccessToken(
            stringValue: expectedAccessTokenString,
            validation: .init(
                userId: userId,
                login: userLogin,
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        let urlSessionConfig = URLSessionConfiguration.default
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        mockAccessTokenStore.tokens[userId] = expectedAccessToken
        clientAuthSession.userId = userId
        
        clientAuthSession.getAccessToken { response in
            switch response.result {
            case .success((let accessToken, _)):
                XCTAssertEqual(accessToken, expectedAccessToken, "Incorrect access token")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenExistsInTokenStore_andDoesNotHaveRecentValidation_getAccessTokenValidatesAndReturnsCurrentAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        let expectedAccessTokenString = "MockAccessToken"
        
        let existingAccessToken = ValidatedUserAccessToken(
            stringValue: expectedAccessTokenString,
            validation: .init(
                userId: userId,
                login: userLogin,
                clientId: clientId,
                scopes: scopes,
                date: Date() - 3600
            )
        )
        
        let data = Data("""
        {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        mockAccessTokenStore.tokens[userId] = existingAccessToken
        clientAuthSession.userId = userId
        clientAuthSession.injectable.webAuthSession = MockASWebAuthSession.init
        
        clientAuthSession.getAccessToken { response in
            switch response.result {
            case .success((let accessToken, _)):
                XCTAssertEqual(accessToken.stringValue, existingAccessToken.stringValue,
                               "Incorrect access token string")
                XCTAssertEqual(accessToken.validation.clientId, existingAccessToken.validation.clientId,
                               "Incorrect client ID")
                XCTAssertEqual(accessToken.validation.userId, existingAccessToken.validation.userId,
                               "Incorrect user ID")
                XCTAssertEqual(accessToken.validation.login, existingAccessToken.validation.login,
                               "Incorrect user login")
                XCTAssertEqual(accessToken.validation.scopes, existingAccessToken.validation.scopes,
                               "Incorrect scopes")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenExistsInTokenStore_andDoesNotHaveRecentValidation_andValidationFails_getAccessTokenReAuthorizesAndReturnsNewAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        let expectedAccessTokenString = "MockAccessToken"
        
        let expectedNonce = UUID().uuidString
        let expectedIdToken = generateIdTokenString(nonce: expectedNonce)
        let state = UUID().uuidString
        
        let data = Data("""
        {
            "user_id": "\(userId)",
            "login": "\(userLogin)",
            "client_id": "\(clientId)",
            "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
        }
        """.utf8)
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        var isFirstValidationAttempt = true
        
        ResponseProvider.requestHandler = { request in
            defer { isFirstValidationAttempt = false }
            if isFirstValidationAttempt {
                throw URLError(.init(rawValue: 0))
            } else {
                return (nil, data)
            }
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.nonce = { expectedNonce }
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)#id_token=\(expectedIdToken)&access_token=\(expectedAccessTokenString)&state=\(state)")
            return session
        }
        
        let existingAccessToken = ValidatedUserAccessToken(
            stringValue: expectedAccessTokenString,
            validation: .init(
                userId: userId,
                login: userLogin,
                clientId: clientId,
                scopes: scopes,
                date: Date() - 3600
            )
        )
        
        mockAccessTokenStore.tokens[userId] = existingAccessToken
        clientAuthSession.userId = userId
        
        clientAuthSession.getAccessToken { response in
            switch response.result {
            case .success((let accessToken, _)):
                XCTAssertEqual(accessToken.stringValue, existingAccessToken.stringValue,
                               "Incorrect access token string")
                XCTAssertEqual(accessToken.validation.clientId, existingAccessToken.validation.clientId,
                               "Incorrect client ID")
                XCTAssertEqual(accessToken.validation.userId, existingAccessToken.validation.userId,
                               "Incorrect user ID")
                XCTAssertEqual(accessToken.validation.login, existingAccessToken.validation.login,
                               "Incorrect user login")
                XCTAssertEqual(accessToken.validation.scopes, existingAccessToken.validation.scopes,
                               "Incorrect scopes")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenDoesNotExistInTokenStore_getAccessTokenReAuthorizesAndReturnsNewAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        let expectedAccessTokenString = "MockAccessToken"
        
        let expectedNonce = UUID().uuidString
        let expectedIdToken = generateIdTokenString(nonce: expectedNonce)
        let state = UUID().uuidString
        
        let data = Data("""
        {
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
            (nil, data)
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.nonce = { expectedNonce }
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)#id_token=\(expectedIdToken)&access_token=\(expectedAccessTokenString)&state=\(state)")
            return session
        }
        
        clientAuthSession.userId = userId
        
        clientAuthSession.getAccessToken { response in
            switch response.result {
            case .success((let accessToken, let idToken)):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token string")
                XCTAssertEqual(accessToken.validation.clientId, self.clientId, "Incorrect client ID")
                XCTAssertEqual(accessToken.validation.userId, self.userId, "Incorrect user ID")
                XCTAssertEqual(accessToken.validation.login, self.userLogin, "Incorrect user login")
                XCTAssertEqual(accessToken.validation.scopes, self.scopes, "Incorrect scopes")
                
                XCTAssertEqual(idToken?.rawValue, expectedIdToken, "Incorrect ID token raw value")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenInAccessTokenStore_revokeCurrentAccessTokenRevokesCurrentAccessToken() {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        mockAccessTokenStore.tokens[userId] = ValidatedUserAccessToken(
            stringValue: "MockAccessToken",
            validation: .init(
                userId: userId,
                login: userLogin,
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        clientAuthSession.injectable.webAuthSession = MockASWebAuthSession.init
        
        clientAuthSession.revokeCurrentAccessToken { response in
            if let error = response.error {
                XCTFail("Expected revoke to not fail, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenInAccessTokenStore_andRevokingFails_revokeCurrentAccessTokenReturnsError() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            throw URLError(.init(rawValue: 0))
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        mockAccessTokenStore.tokens[userId] = ValidatedUserAccessToken(
            stringValue: "MockAccessToken",
            validation: .init(
                userId: userId,
                login: userLogin,
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        clientAuthSession.injectable.webAuthSession = MockASWebAuthSession.init
        
        clientAuthSession.revokeCurrentAccessToken { response in
            if response.error == nil {
                XCTFail("Expected revoke to return error")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenNoAccessTokenInAccessTokenStore_revokeCurrentAccessTokenReturnsError() {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.webAuthSession = MockASWebAuthSession.init
        
        clientAuthSession.revokeCurrentAccessToken { response in
            if response.error == nil {
                XCTFail("Expected revoke to return error")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_convenienceInit_initializesWithKeychainAccessTokenStore() {
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, nil)
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        XCTAssertTrue(clientAuthSession.accessTokenStore.baseTokenStore is KeychainUserAccessTokenStore,
                      "Expected access token store to be a \(KeychainUserAccessTokenStore.self)")
    }
    
    func test_urlSessionConfiguration_returnsURLSessionConfigurationOfInternalURLSession() {
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, nil)
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        XCTAssertEqual(clientAuthSession.urlSessionConfiguration, urlSessionConfig,
                       "Expected URL session config to be equal to the passed-in config")
        
        XCTAssertEqual(clientAuthSession.urlSessionConfiguration, clientAuthSession.urlSession.configuration,
                       "Expected URL session config to be equal to the internal URL session's config")
    }
    
    func test_givenAccessTokenInTokenStore_getCurrentAccessTokenReturnsThatAccessToken() {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        let expectedAccessToken = ValidatedUserAccessToken(
            stringValue: "MockAccessToken",
            validation: .init(
                userId: userId,
                login: userLogin,
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        mockAccessTokenStore.tokens[userId] = expectedAccessToken
        
        clientAuthSession.getCurrentAccessToken { result in
            switch result {
            case .success(let accessToken):
                XCTAssertEqual(accessToken, expectedAccessToken, "Incorrect access token")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenExistingFlow_getNewAccessTokenReturnsOperationInProgressError() {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.shouldCallCompletionHandler = false
            return session
        }
        
        clientAuthSession.getNewAccessToken { _ in }
        
        clientAuthSession.getNewAccessToken { response in
            switch response.result {
            case .success:
                XCTFail("Expected to get error")
                
            case .failure(ClientAuthSession.Error.operationInProgress):
                break
                
            case .failure(let error):
                XCTFail("Expected to get \(ClientAuthSession.Error.operationInProgress), got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenExistingFlow_getIdTokenReturnsOperationInProgressError() {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.shouldCallCompletionHandler = false
            return session
        }
        
        clientAuthSession.getNewAccessToken { _ in }
        
        clientAuthSession.getIdToken { result in
            switch result {
            case .success:
                XCTFail("Expected to get error")
                
            case .failure(ClientAuthSession.Error.operationInProgress):
                break
                
            case .failure(let error):
                XCTFail("Expected to get \(ClientAuthSession.Error.operationInProgress), got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenExistingFlow_getAuthCodeReturnsOperationInProgressError() {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.shouldCallCompletionHandler = false
            return session
        }
        
        clientAuthSession.getNewAccessToken { _ in }
        
        clientAuthSession.getAuthCode { result in
            switch result {
            case .success:
                XCTFail("Expected to get error")
                
            case .failure(ClientAuthSession.Error.operationInProgress):
                break
                
            case .failure(let error):
                XCTFail("Expected to get \(ClientAuthSession.Error.operationInProgress), got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenExistingFlow_cancelAuthCancelsCurrentAuthFlow() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedNonce = UUID().uuidString
        let expectedIdToken = generateIdTokenString(nonce: expectedNonce)
        let state = UUID().uuidString
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, nil)
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.nonce = { expectedNonce }
        clientAuthSession.injectable.state = { state }
        
        var isFirstWebAuthSession = true
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            if isFirstWebAuthSession {
                session.shouldCallCompletionHandler = false
            } else {
                session.callbackURL = URL(string: "\(self.redirectURLString)#id_token=\(expectedIdToken)&state=\(state)")
            }
            isFirstWebAuthSession = false
            return session
        }
        
        clientAuthSession.getNewAccessToken { _ in }
        
        clientAuthSession.cancelAuth()
        
        clientAuthSession.getIdToken { result in
            switch result {
            case .success:
                break
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenOIDCAuthFlow_andValidationFails_getNewAccessTokenReturnsError() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedNonce = UUID().uuidString
        let expectedIdToken = generateIdTokenString(nonce: expectedNonce)
        let expectedAccessTokenString = "MockAccessToken"
        let state = UUID().uuidString
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            throw URLError(.init(rawValue: 0))
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.nonce = { expectedNonce }
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)#id_token=\(expectedIdToken)&access_token=\(expectedAccessTokenString)&state=\(state)")
            return session
        }
        
        clientAuthSession.getNewAccessToken { response in
            switch response.result {
            case .success:
                XCTFail("Expected to get error")
                
            case .failure:
                break
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenOAuthAuthFlow_andValidationFails_getNewAccessTokenReturnsError() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedAccessTokenString = "MockAccessToken"
        let state = UUID().uuidString
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            throw URLError(.init(rawValue: 0))
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .oAuth(forceVerify: false),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)#access_token=\(expectedAccessTokenString)&state=\(state)")
            return session
        }
        
        clientAuthSession.getNewAccessToken { response in
            switch response.result {
            case .success:
                XCTFail("Expected to get error")
                
            case .failure:
                break
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenOAuthAuthFlow_andWebAuthSessionFails_getNewAccessTokenReturnsError() {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .oAuth(forceVerify: false),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackError = URLError(.init(rawValue: 0))
            return session
        }
        
        clientAuthSession.getNewAccessToken { response in
            switch response.result {
            case .success:
                XCTFail("Expected to get error")
                
            case .failure:
                break
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenOAuthAuthCodeFlow_andWebAuthSessionFails_getAuthCodeReturnsError() {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .oAuth(forceVerify: false),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackError = URLError(.init(rawValue: 0))
            return session
        }
        
        clientAuthSession.getAuthCode { result in
            switch result {
            case .success:
                XCTFail("Expected to get error")
                
            case .failure:
                break
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenOIDCAuthCodeFlow_andWebAuthSessionFails_getAuthCodeReturnsError() {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackError = URLError(.init(rawValue: 0))
            return session
        }
        
        clientAuthSession.getAuthCode { result in
            switch result {
            case .success:
                XCTFail("Expected to get error")
                
            case .failure:
                break
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_ifValidationSucceeds_butStoringTheTokenFails_getNewAccessTokenReturnsError() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        let expectedNonce = UUID().uuidString
        let expectedIdToken = generateIdTokenString(nonce: expectedNonce)
        let expectedAccessTokenString = "MockAccessToken"
        let state = UUID().uuidString
        
        let data = Data("""
        {
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
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: URL(string: redirectURLString)!,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: nil,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: nil,
            urlSessionConfiguration: urlSessionConfig
        )
        
        mockAccessTokenStore.shouldStoreFail = true
        
        clientAuthSession.injectable.nonce = { expectedNonce }
        clientAuthSession.injectable.state = { state }
        clientAuthSession.injectable.webAuthSession = {
            let session = MockASWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(self.redirectURLString)#id_token=\(expectedIdToken)&access_token=\(expectedAccessTokenString)&state=\(state)")
            return session
        }
        
        clientAuthSession.getNewAccessToken { response in
            switch response.result {
            case .success:
                XCTFail("Expected to get error")
                
            case .failure:
                break
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    var mockPresentationContextProvider: MockPresentationContextProvider!
    
    func test_presentationAnchorForSession_returnsWindowOfPresentationContextProvider() {
        let redirectURL = URL(string: "redirectURLString")!
        
        mockPresentationContextProvider = .init()
        mockPresentationContextProvider.anchor = PresentationAnchor()
        
        clientAuthSession = .init(
            clientId: clientId,
            redirectURL: redirectURL,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            userId: userId,
            defaultAuthFlow: .openId(claims: .all),
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            urlSessionConfiguration: .default
        )
        
        let webAuthSession = WebAuthenticationSession(clientId: clientId,
                                                      redirectURL: redirectURL,
                                                      scopes: scopes,
                                                      flow: .accessToken(forceVerify: false, completion: { _ in }))
        let anchor = clientAuthSession.presentationAnchor(for: webAuthSession)
        
        XCTAssertEqual(anchor, mockPresentationContextProvider.anchor, "Incorrect presentation anchor")
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
