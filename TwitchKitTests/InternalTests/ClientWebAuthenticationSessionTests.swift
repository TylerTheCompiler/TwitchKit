//
//  ClientWebAuthenticationSessionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
import AuthenticationServices
@testable import TwitchKit

class MockWebAuthSession: WebAuthSessionProtocol {
    var canStart = true
    var wasCancelled = false
    
    var url: URL
    var callbackURLScheme: String?
    var completionHandler: ASWebAuthenticationSession.CompletionHandler
    
    var prefersEphemeralWebBrowserSession = false
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
    
    var shouldCallCompletionHandler = true
    var callbackURL: URL?
    var callbackError: Error?
    
    required init(url: URL,
                  callbackURLScheme: String?,
                  completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler) {
        self.url = url
        self.callbackURLScheme = callbackURLScheme
        self.completionHandler = completionHandler
    }
    
    func start() -> Bool {
        canStart = false
        
        if shouldCallCompletionHandler {
            let completionHandler = self.completionHandler
            DispatchQueue.main.async {
                completionHandler(self.callbackURL, self.callbackError)
                self.canStart = true
            }
        }
        
        return true
    }
    
    func cancel() {
        wasCancelled = true
        canStart = false
        let completionHandler = self.completionHandler
        DispatchQueue.main.async {
            completionHandler(nil, self.callbackError)
        }
    }
}

class MockPresentationContextProvider: NSObject, SessionPresentationContextProviding, ClientAuthSessionPresentationContextProviding {
    var anchor: PresentationAnchor!
    
    func presentationAnchor(for session: ClientWebAuthenticationSession) -> PresentationAnchor {
        anchor
    }
    
    func presentationAnchor(for session: ClientAuthSession) -> PresentationAnchor {
        anchor
    }
}

class ClientWebAuthenticationSessionTests: XCTestCase {
    var mockPresentationContextProvider: MockPresentationContextProvider!
    var clientWebAuthSession: ClientWebAuthenticationSession!
    
    override func setUp() {
        mockPresentationContextProvider = .init()
    }
    
    override func tearDown() {
        clientWebAuthSession = nil
        mockPresentationContextProvider = nil
    }
    
    // MARK: - Starting and Cancelling
    
    func test_presentationContextProvider_returnsPreviouslySetValue() throws {
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken { _ in }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        XCTAssertEqual(clientWebAuthSession.presentationContextProvider as? MockPresentationContextProvider,
                       mockPresentationContextProvider,
                       "Expected presentationContextProvider to be the test case")
        
        clientWebAuthSession.presentationContextProvider = nil
        
        XCTAssertNil(clientWebAuthSession.presentationContextProvider,
                     "Expected presentationContextProvider to be set to nil")
        
        clientWebAuthSession.presentationContextProvider = mockPresentationContextProvider
        
        XCTAssertEqual(clientWebAuthSession.presentationContextProvider as? MockPresentationContextProvider,
                       mockPresentationContextProvider,
                       "Expected presentationContextProvider to be set to the test case again")
    }
    
    func test_given_noPresentationContextProvider_canStart_returnsFalse_and_startFails() throws {
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: nil,
            flow: .accessToken { _ in }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        XCTAssertFalse(clientWebAuthSession.canStart,
                       "Expected canStart to return false when presentationContextProvider is nil")
        
        XCTAssertFalse(clientWebAuthSession.start(),
                       "Expected start to return false when presentationContextProvider is nil")
    }
    
    func test_cancel_cancelsAuthFlow() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: false) { _ in
                XCTAssertTrue(webAuthSession.wasCancelled, "Expected web auth session to be cancelled")
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            webAuthSession.shouldCallCompletionHandler = false
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        clientWebAuthSession.cancel()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    // MARK: - Access Token Flow
    
    func test_accessTokenFlow_success_returnsAccessToken() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedAccessToken = "MockAccessToken"
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: false) { result in
                switch result {
                case .success(let userAccessToken):
                    XCTAssertEqual(userAccessToken.stringValue, expectedAccessToken,
                                   "Expected access token in returned URL to match expected access token")
                    
                case .failure:
                    XCTFail("Expected auth flow to not fail")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#access_token=\(expectedAccessToken)&state=\(state)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_accessTokenFlow_invalidURLComponents_sessionDoesNotStart() throws {
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: false) { _ in }
        )
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example"
        components.path = "badpath"
        clientWebAuthSession.injectable.urlComponents = { _ in components }
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        XCTAssertFalse(clientWebAuthSession.start(), "Expected client web auth session to not start")
    }
    
    func test_accessTokenFlow_forceVerify_isSetToTrue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: true) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                XCTAssertTrue(queryItems.contains(.init(name: "force_verify", value: "true")),
                              "Expected \"force_verify\" query item to be \"true\"")
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_accessTokenFlow_forceVerify_isSetToFalse() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: false) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                XCTAssertTrue(queryItems.contains(.init(name: "force_verify", value: "false")),
                              "Expected \"force_verify\" query item to be \"false\"")
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_accessTokenFlow_receivingWebAuthSessionError_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedError = NSError(domain: "Test error", code: 0)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: false) { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    XCTAssertEqual(error as NSError, expectedError,
                                   "Expected returned error to be the expected error")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackError = expectedError
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_accessTokenFlow_missingOrInvalidCallbackURL_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: false) { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingOrInvalidCallbackURL:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing callback URL")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = nil
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_accessTokenFlow_mismatchedState_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let accessToken = "MockAccessToken"
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: false) { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.mismatchedState:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to mismatched state")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#access_token=\(accessToken)&state=someState")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_accessTokenFlow_missingAccessToken_causesFailure() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: false) { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingAccessToken:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing access token")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#state=\(state)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    // MARK: - ID and Access Token Flow
    
    func test_idAndAccessTokenFlow_success_returnsIdAndAccessToken() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedNonce = UUID().uuidString
        let expectedIdToken = generateIdTokenString(nonce: expectedNonce)
        let expectedAccessToken = "MockAccessToken"
        let redirectURLString = "mockscheme://mockhost"
        let expectedState = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken(claims: .all) { result in
                switch result {
                case .success((let idToken, let userAccessToken)):
                    XCTAssertEqual(idToken.stringValue, expectedIdToken,
                                   "Expected ID token in returned URL to match expected ID token")
                    
                    XCTAssertEqual(userAccessToken.stringValue, expectedAccessToken,
                                   "Expected access token in returned URL to match expected access token")
                    
                case .failure:
                    XCTFail("Expected auth flow to not fail")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { expectedState }
        clientWebAuthSession.injectable.nonce = { expectedNonce }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#id_token=\(expectedIdToken)&access_token=\(expectedAccessToken)&state=\(expectedState)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idAndAccessTokenFlow_invalidURLComponents_sessionDoesNotStart() throws {
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken(claims: []) { _ in }
        )
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example"
        components.path = "badpath"
        clientWebAuthSession.injectable.urlComponents = { _ in components }
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        XCTAssertFalse(clientWebAuthSession.start(), "Expected client web auth session to not start")
    }
    
    func test_idAndAccessTokenFlow_claims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        let idTokenClaims = Set([Claim.email, .picture, .preferredUsername, .updatedAt])
        let userinfoClaims = Set([Claim.email, .emailVerified])
        let expectedClaims = Claims(idTokenClaims: idTokenClaims, userinfoClaims: userinfoClaims)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken(claims: idTokenClaims.intersection(userinfoClaims),
                                    idTokenClaims: idTokenClaims,
                                    userinfoClaims: userinfoClaims) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let actualClaims = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTAssertEqual(actualClaims, expectedClaims,
                                  "Expected \"claims\" query item to be equal to expected claims")
                } catch {
                    XCTFail("Expected claims to be in valid JSON format")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idAndAccessTokenFlow_justIdTokenClaims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        let claimsSet = Set([Claim.email, .emailVerified, .picture, .preferredUsername, .updatedAt])
        let expectedClaims = Claims(idTokenClaims: claimsSet, userinfoClaims: [])
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken(idTokenClaims: claimsSet) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let actualClaims = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTAssertEqual(actualClaims, expectedClaims,
                                  "Expected \"claims\" query item to be equal to expected claims")
                } catch {
                    XCTFail("Expected claims to be in valid JSON format")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idAndAccessTokenFlow_justUserinfoClaims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        let claimsSet = Set([Claim.email, .emailVerified, .picture, .preferredUsername, .updatedAt])
        let expectedClaims = Claims(idTokenClaims: [], userinfoClaims: claimsSet)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken(userinfoClaims: claimsSet) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let actualClaims = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTAssertEqual(actualClaims, expectedClaims,
                                  "Expected \"claims\" query item to be equal to expected claims")
                } catch {
                    XCTFail("Expected claims to be in valid JSON format")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idAndAccessTokenFlow_emptyClaims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    _ = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTFail("Expected \"claims\" query item to not exist")
                } catch {}
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idAndAccessTokenFlow_receivingWebAuthSessionError_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedError = NSError(domain: "Test error", code: 0)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    XCTAssertEqual(error as NSError, expectedError,
                                   "Expected returned error to be the expected error")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackError = expectedError
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idAndAccessTokenFlow_missingOrInvalidCallbackURL_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingOrInvalidCallbackURL:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing callback URL")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = nil
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idAndAccessTokenFlow_mismatchedState_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let accessToken = "MockAccessToken"
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.mismatchedState:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to mismatched state")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#access_token=\(accessToken)&state=someState")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idAndAccessTokenFlow_missingAccessToken_causesFailure() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingAccessToken:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing access token")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#id_token=someIdToken&state=\(state)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idAndAccessTokenFlow_missingIdToken_causesFailure() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idAndAccessToken { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingIdToken:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing ID token")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#access_token=someAccessToken&state=\(state)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    // MARK: - ID Token Flow
    
    func test_idTokenFlow_success_returnsIdToken() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedNonce = UUID().uuidString
        let expectedIdToken = generateIdTokenString(nonce: expectedNonce)
        let redirectURLString = "mockscheme://mockhost"
        let expectedState = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken(claims: .all) { result in
                switch result {
                case .success(let idToken):
                    XCTAssertEqual(idToken.stringValue, expectedIdToken,
                                   "Expected ID token in returned URL to match expected ID token")
                    
                case .failure:
                    XCTFail("Expected auth flow to not fail")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { expectedState }
        clientWebAuthSession.injectable.nonce = { expectedNonce }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#id_token=\(expectedIdToken)&state=\(expectedState)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idTokenFlow_invalidURLComponents_sessionDoesNotStart() throws {
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken(claims: []) { _ in }
        )
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example"
        components.path = "badpath"
        clientWebAuthSession.injectable.urlComponents = { _ in components }
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        XCTAssertFalse(clientWebAuthSession.start(), "Expected client web auth session to not start")
    }
    
    func test_idTokenFlow_claims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        let idTokenClaims = Set([Claim.email, .picture, .preferredUsername, .updatedAt])
        let userinfoClaims = Set([Claim.email, .emailVerified])
        let expectedClaims = Claims(idTokenClaims: idTokenClaims, userinfoClaims: userinfoClaims)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken(claims: idTokenClaims.intersection(userinfoClaims),
                           idTokenClaims: idTokenClaims,
                           userinfoClaims: userinfoClaims) { result in
                            let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let actualClaims = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTAssertEqual(actualClaims, expectedClaims,
                                  "Expected \"claims\" query item to be equal to expected claims")
                } catch {
                    XCTFail("Expected claims to be in valid JSON format")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idTokenFlow_justIdTokenClaims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        let claimsSet = Set([Claim.email, .emailVerified, .picture, .preferredUsername, .updatedAt])
        let expectedClaims = Claims(idTokenClaims: claimsSet, userinfoClaims: [])
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken(idTokenClaims: claimsSet) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let actualClaims = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTAssertEqual(actualClaims, expectedClaims,
                                  "Expected \"claims\" query item to be equal to expected claims")
                } catch {
                    XCTFail("Expected claims to be in valid JSON format")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idTokenFlow_justUserinfoClaims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        let claimsSet = Set([Claim.email, .emailVerified, .picture, .preferredUsername, .updatedAt])
        let expectedClaims = Claims(idTokenClaims: [], userinfoClaims: claimsSet)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken(userinfoClaims: claimsSet) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let actualClaims = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTAssertEqual(actualClaims, expectedClaims,
                                  "Expected \"claims\" query item to be equal to expected claims")
                } catch {
                    XCTFail("Expected claims to be in valid JSON format")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idTokenFlow_emptyClaims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    _ = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTFail("Expected \"claims\" query item to not exist")
                } catch {}
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idTokenFlow_receivingWebAuthSessionError_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedError = NSError(domain: "Test error", code: 0)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    XCTAssertEqual(error as NSError, expectedError,
                                   "Expected returned error to be the expected error")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackError = expectedError
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idTokenFlow_missingOrInvalidCallbackURL_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingOrInvalidCallbackURL:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing callback URL")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = nil
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idTokenFlow_mismatchedState_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.mismatchedState:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to mismatched state")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#state=someState")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_idTokenFlow_missingIdToken_causesFailure() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .idToken { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingIdToken:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing ID token")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)#state=\(state)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    // MARK: - Auth Code (OAuth) Flow
    
    func test_authCodeOAuthFlow_success_returnsAuthCode() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedAuthCode = "MockAuthCode"
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOAuth(forceVerify: true) { result in
                switch result {
                case .success(let authCode):
                    XCTAssertEqual(authCode.rawValue, expectedAuthCode,
                                   "Expected auth code in returned URL to match expected auth code")
                    
                case .failure:
                    XCTFail("Expected auth flow to not fail")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)?code=\(expectedAuthCode)&state=\(state)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOAuthFlow_invalidURLComponents_sessionDoesNotStart() throws {
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOAuth(forceVerify: false) { _ in }
        )
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example"
        components.path = "badpath"
        clientWebAuthSession.injectable.urlComponents = { _ in components }
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        XCTAssertFalse(clientWebAuthSession.start(), "Expected client web auth session to not start")
    }
    
    func test_authCodeOAuthFlow_forceVerify_isSetToTrue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOAuth(forceVerify: true) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                XCTAssertTrue(queryItems.contains(.init(name: "force_verify", value: "true")),
                              "Expected \"force_verify\" query item to be \"true\"")
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOAuthFlow_forceVerify_isSetToFalse() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOAuth(forceVerify: false) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                XCTAssertTrue(queryItems.contains(.init(name: "force_verify", value: "false")),
                              "Expected \"force_verify\" query item to be \"false\"")
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOAuthFlow_receivingWebAuthSessionError_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedError = NSError(domain: "Test error", code: 0)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOAuth(forceVerify: false) { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    XCTAssertEqual(error as NSError, expectedError,
                                   "Expected returned error to be the expected error")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackError = expectedError
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOAuthFlow_missingOrInvalidCallbackURL_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOAuth(forceVerify: false) { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingOrInvalidCallbackURL:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing callback URL")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = nil
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOAuthFlow_mismatchedState_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOAuth(forceVerify: false) { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.mismatchedState:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to mismatched state")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)?state=someState")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOAuthFlow_missingAuthCode_causesFailure() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOAuth(forceVerify: false) { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingAuthCode:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing auth code")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)?state=\(state)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    // MARK: - Auth Code (OIDC) Flow
    
    func test_authCodeOIDCFlow_success_returnsIdAndAccessToken() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedNonce = UUID().uuidString
        let expectedAuthCode = "MockAuthCode"
        let redirectURLString = "mockscheme://mockhost"
        let expectedState = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC(claims: .all) { result in
                switch result {
                case .success((let authCode, let actualNonce)):
                    XCTAssertEqual(authCode.rawValue, expectedAuthCode,
                                   "Expected auth code in returned URL to match expected auth code")
                    
                    XCTAssertEqual(actualNonce, expectedNonce,
                                   "Expected nonce in returned URL to match expected nonce")
                    
                case .failure:
                    XCTFail("Expected auth flow to not fail")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { expectedState }
        clientWebAuthSession.injectable.nonce = { expectedNonce }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)?code=\(expectedAuthCode)&state=\(expectedState)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOIDCFlow_invalidURLComponents_sessionDoesNotStart() throws {
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC(claims: []) { _ in }
        )
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example"
        components.path = "badpath"
        clientWebAuthSession.injectable.urlComponents = { _ in components }
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        XCTAssertFalse(clientWebAuthSession.start(), "Expected client web auth session to not start")
    }
    
    func test_authCodeOIDCFlow_claims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        let idTokenClaims = Set([Claim.email, .picture, .preferredUsername, .updatedAt])
        let userinfoClaims = Set([Claim.email, .emailVerified])
        let expectedClaims = Claims(idTokenClaims: idTokenClaims, userinfoClaims: userinfoClaims)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC(claims: idTokenClaims.intersection(userinfoClaims),
                                     idTokenClaims: idTokenClaims,
                                     userinfoClaims: userinfoClaims) { result in
                                        let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let actualClaims = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTAssertEqual(actualClaims, expectedClaims,
                                  "Expected \"claims\" query item to be equal to expected claims")
                } catch {
                    XCTFail("Expected claims to be in valid JSON format")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOIDCFlow_justIdTokenClaims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        let claimsSet = Set([Claim.email, .emailVerified, .picture, .preferredUsername, .updatedAt])
        let expectedClaims = Claims(idTokenClaims: claimsSet, userinfoClaims: [])
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC(idTokenClaims: claimsSet) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let actualClaims = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTAssertEqual(actualClaims, expectedClaims,
                                  "Expected \"claims\" query item to be equal to expected claims")
                } catch {
                    XCTFail("Expected claims to be in valid JSON format")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOIDCFlow_justUserinfoClaims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        let claimsSet = Set([Claim.email, .emailVerified, .picture, .preferredUsername, .updatedAt])
        let expectedClaims = Claims(idTokenClaims: [], userinfoClaims: claimsSet)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC(userinfoClaims: claimsSet) { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let actualClaims = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTAssertEqual(actualClaims, expectedClaims,
                                  "Expected \"claims\" query item to be equal to expected claims")
                } catch {
                    XCTFail("Expected claims to be in valid JSON format")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOIDCFlow_emptyClaims_isExpectedValue() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        var webAuthSession: MockWebAuthSession!
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC { result in
                let components = URLComponents(string: webAuthSession.url.absoluteString)!
                let queryItems = components.queryItems ?? []
                let claimsQueryItemData = Data((queryItems.first { $0.name == "claims" }?.value ?? "").utf8)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    _ = try decoder.decode(Claims.self, from: claimsQueryItemData)
                    
                    XCTFail("Expected \"claims\" query item to not exist")
                } catch {}
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            webAuthSession = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            return webAuthSession
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOIDCFlow_receivingWebAuthSessionError_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let expectedError = NSError(domain: "Test error", code: 0)
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    XCTAssertEqual(error as NSError, expectedError,
                                   "Expected returned error to be the expected error")
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackError = expectedError
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOIDCFlow_missingOrInvalidCallbackURL_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingOrInvalidCallbackURL:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing callback URL")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = nil
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOIDCFlow_mismatchedState_causesFailure() {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.mismatchedState:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to mismatched state")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)?state=someState")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_authCodeOIDCFlow_missingAuthCode_causesFailure() throws {
        let authFlowToComplete = expectation(description: "Expected auth flow to complete")
        let redirectURLString = "mockscheme://mockhost"
        let state = UUID().uuidString
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: redirectURLString)!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .authCodeUsingOIDC { result in
                switch result {
                case .success:
                    XCTFail("Expected auth flow to fail")
                    
                case .failure(let error):
                    switch error {
                    case ClientWebAuthenticationSession.Error.missingAuthCode:
                        break
                        
                    default:
                        XCTFail("Expected auth flow to fail due to missing auth code")
                    }
                }
                
                authFlowToComplete.fulfill()
            }
        )
        
        clientWebAuthSession.injectable.state = { state }
        clientWebAuthSession.injectable.webAuthSession = {
            let session = MockWebAuthSession(url: $0, callbackURLScheme: $1, completionHandler: $2)
            session.callbackURL = URL(string: "\(redirectURLString)?state=\(state)")
            return session
        }
        
        clientWebAuthSession.start()
        
        wait(for: [authFlowToComplete], timeout: 1.0)
    }
    
    func test_presentationAnchorForSession_returnsWindowOfPresentationContextProvider() {
        mockPresentationContextProvider.anchor = PresentationAnchor()
        
        clientWebAuthSession = .init(
            clientId: "MockClientId",
            redirectURL: URL(string: "mockscheme://mockhost")!,
            scopes: .all,
            prefersEphemeralWebBrowserSession: false,
            presentationContextProvider: mockPresentationContextProvider,
            flow: .accessToken(forceVerify: false, completion: { _ in })
        )
        
        let asWebAuthSession = ASWebAuthenticationSession(url: URL(string: "https://id.twitch.tv")!,
                                                          callbackURLScheme: "mockscheme") { _, _ in }
        let anchor = clientWebAuthSession.presentationAnchor(for: asWebAuthSession)
        
        XCTAssertEqual(anchor, mockPresentationContextProvider.anchor, "Incorrect presentation anchor")
    }
    
    // MARK: - Private Helpers
    
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
