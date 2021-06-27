//
//  ServerAppAuthSessionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/12/20.
//

import XCTest
@testable import TwitchKit

class ServerAppAuthSessionTests: XCTestCase {
    var mockAccessTokenStore: MockAuthTokenStore<ValidatedAppAccessToken>!
    var serverAppAuthSession: ServerAppAuthSession!
    
    var clientId = "MockClientId"
    var clientSecret = "MockClientSecret"
    var scopes = Set<Scope>.all
    
    override func setUp() {
        mockAccessTokenStore = .init()
        mockAccessTokenStore.shouldUseSingleToken = true
    }
    
    override func tearDown() {
        serverAppAuthSession = nil
        mockAccessTokenStore = nil
    }
    
    func test_convenienceInit_initializesWithKeychainAccessTokenStores() {
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, nil)
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            urlSessionConfiguration: urlSessionConfig
        )
        
        XCTAssertTrue(serverAppAuthSession.accessTokenStore.baseTokenStore is KeychainAppAccessTokenStore,
                      "Expected access token store to be a \(KeychainAppAccessTokenStore.self)")
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
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            urlSessionConfiguration: urlSessionConfig
        )
        
        XCTAssertEqual(serverAppAuthSession.urlSessionConfiguration, urlSessionConfig,
                       "Expected URL session config to be equal to the passed-in config")
        
        XCTAssertEqual(serverAppAuthSession.urlSessionConfiguration, serverAppAuthSession.urlSession.configuration,
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
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        let expectedAccessToken = ValidatedAppAccessToken(
            stringValue: "MockAccessToken",
            validation: .init(
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        mockAccessTokenStore.token = expectedAccessToken
        
        serverAppAuthSession.getCurrentAccessToken { result in
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
    
    func test_givenAccessTokenInTokenStore_andAccessTokenIsRecent_getAccessTokenReturnsThatAccessToken() {
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
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        let expectedAccessToken = ValidatedAppAccessToken(
            stringValue: "MockAccessToken",
            validation: .init(
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        mockAccessTokenStore.token = expectedAccessToken
        
        serverAppAuthSession.getAccessToken { result in
            switch result {
            case .success((let accessToken, _)):
                XCTAssertEqual(accessToken, expectedAccessToken, "Incorrect access token")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenInTokenStore_andAccessTokenIsNotRecent_getAccessTokenValidatesAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        let validateData = Data("""
        {
            "client_id": "\(clientId)",
            "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
        }
        """.utf8)
        
        ResponseProvider.requestHandler = { request in
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            return (nil, validateData)
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        let expectedAccessTokenString = "MockAccessToken"
        
        let accessToken = ValidatedAppAccessToken(
            stringValue: expectedAccessTokenString,
            validation: .init(
                clientId: clientId,
                scopes: scopes,
                date: .distantPast
            )
        )
        
        mockAccessTokenStore.token = accessToken
        
        serverAppAuthSession.getAccessToken { result in
            switch result {
            case .success((let accessToken, _)):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenInTokenStore_andAccessTokenIsNotRecent_andValidationFails_getAccessTokenGetsNewAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        let expectedAccessTokenString = "MockAccessToken"
        
        let authorizeData = Data("""
        {
            "access_token": "\(expectedAccessTokenString)"
        }
        """.utf8)
        
        let validateData = Data("""
        {
            "client_id": "\(clientId)",
            "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
        }
        """.utf8)
        
        var requestCount = 0
        
        ResponseProvider.requestHandler = { request in
            defer { requestCount += 1 }
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            switch requestCount {
            case 0: throw URLError(.init(rawValue: 0))
            case 1: return (nil, authorizeData)
            default: return (nil, validateData)
            }
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        let accessToken = ValidatedAppAccessToken(
            stringValue: expectedAccessTokenString,
            validation: .init(
                clientId: clientId,
                scopes: scopes,
                date: .distantPast
            )
        )
        
        mockAccessTokenStore.token = accessToken
        
        serverAppAuthSession.getAccessToken { result in
            switch result {
            case .success((let accessToken, _)):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenNotInTokenStore_getAccessTokenGetsNewAccessToken() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        let expectedAccessTokenString = "MockAccessToken"
        
        let authorizeData = Data("""
        {
            "access_token": "\(expectedAccessTokenString)"
        }
        """.utf8)
        
        let validateData = Data("""
        {
            "client_id": "\(clientId)",
            "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
        }
        """.utf8)
        
        var requestCount = 0
        
        ResponseProvider.requestHandler = { request in
            defer { requestCount += 1 }
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            switch requestCount {
            case 0: return (nil, authorizeData)
            default: return (nil, validateData)
            }
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        serverAppAuthSession.getAccessToken { result in
            switch result {
            case .success((let accessToken, _)):
                XCTAssertEqual(accessToken.stringValue, expectedAccessTokenString, "Incorrect access token")
                
            case .failure(let error):
                XCTFail("Expected to not get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_getNewAccessToken_ifFailureHappens_returnsError() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            throw URLError(.init(rawValue: 0))
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        serverAppAuthSession.getAccessToken { result in
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
    
    func test_getNewAccessToken_ifFailsToStoreAccessTokenInTokenStore_returnsError() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        let expectedAccessTokenString = "MockAccessToken"
        
        let authorizeData = Data("""
        {
            "access_token": "\(expectedAccessTokenString)"
        }
        """.utf8)
        
        let validateData = Data("""
        {
            "client_id": "\(clientId)",
            "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
        }
        """.utf8)
        
        var requestCount = 0
        
        ResponseProvider.requestHandler = { request in
            defer { requestCount += 1 }
            guard let url = request.url, url.host == "id.twitch.tv" else { throw URLError(.init(rawValue: 0)) }
            switch requestCount {
            case 0: return (nil, authorizeData)
            default: return (nil, validateData)
            }
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        mockAccessTokenStore.shouldStoreFail = true
        
        serverAppAuthSession.getAccessToken { result in
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
    
    func test_givenAccessTokenInTokenStore_revokeAccessTokenRevokesAccessToken() {
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
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        let expectedAccessToken = ValidatedAppAccessToken(
            stringValue: "MockAccessToken",
            validation: .init(
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        mockAccessTokenStore.token = expectedAccessToken
        
        serverAppAuthSession.revokeCurrentAccessToken { result in
            switch result {
            case .success:
                break
                
            case .failure(let error):
                XCTFail("Expected not to get error, got: \(error)")
            }
            
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenAccessTokenInTokenStore_andRevokeAccessTokenFails_returnsError() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            throw URLError(.init(rawValue: 0))
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        let expectedAccessToken = ValidatedAppAccessToken(
            stringValue: "MockAccessToken",
            validation: .init(
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        mockAccessTokenStore.token = expectedAccessToken
        
        serverAppAuthSession.revokeCurrentAccessToken { result in
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
    
    func test_givenAccessTokenNotInTokenStore_revokeAccessTokenReturnsError() {
        let taskToFinish = expectation(description: "Expected task to finish")
        
        enum ResponseProvider: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        ResponseProvider.requestHandler = { request in
            return (nil, nil)
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.protocolClasses = [MockURLProtocol<ResponseProvider>.self]
        
        serverAppAuthSession = .init(
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            urlSessionConfiguration: urlSessionConfig
        )
        
        serverAppAuthSession.revokeCurrentAccessToken { result in
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
}
