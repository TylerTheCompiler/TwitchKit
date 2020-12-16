//
//  AnyAuthTokenStoreTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

struct MockAuthToken: AuthToken {
    let stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init(from decoder: Decoder) throws {
        stringValue = try decoder.singleValueContainer().decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

class MockAuthTokenStore<Token>: AuthTokenStoring where Token: AuthToken {
    var tokens = [String: Token]()
    var shouldStoreFail = false
    
    func fetchAuthToken(forUserId userId: String?, completion: @escaping (Result<Token, Error>) -> Void) {
        if let userId = userId, let token = tokens[userId] {
            DispatchQueue.main.async {
                completion(.success(token))
            }
        } else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "MockAuthTokenStore Error", code: 0)))
            }
        }
    }
    
    func store(authToken: Token?, forUserId userId: String?, completion: ((Error?) -> Void)?) {
        if let userId = userId, !shouldStoreFail {
            tokens[userId] = authToken
            DispatchQueue.main.async {
                completion?(nil)
            }
        } else {
            DispatchQueue.main.async {
                completion?(NSError(domain: "MockAuthTokenStore Error", code: 0))
            }
        }
    }
}

class AnyAuthTokenStoreTests: XCTestCase {
    var authTokenStore: MockAuthTokenStore<MockAuthToken>!
    var anyAuthTokenStore: AnyAuthTokenStore<MockAuthToken>!

    override func setUpWithError() throws {
        authTokenStore = MockAuthTokenStore()
        anyAuthTokenStore = .init(authTokenStore)
    }

    override func tearDownWithError() throws {
        anyAuthTokenStore = nil
        authTokenStore = nil
    }

    func testTokenStore() throws {
        let token = MockAuthToken(stringValue: "MockAuthToken")
        let userId = "TestUserID"
        
        XCTAssertNotEqual(authTokenStore.tokens[userId], token,
                          "Expected token to not exist in token store before storing it")
        
        let storeToBeCalled = expectation(description: "Expected store method to be called")
        anyAuthTokenStore.store(authToken: token, forUserId: userId) { error in
            XCTAssertEqual(self.authTokenStore.tokens[userId], token,
                           "Expected token to exist in token store after storing it")
            XCTAssertNil(error, "Expected error to be nil")
            storeToBeCalled.fulfill()
        }
        
        wait(for: [storeToBeCalled], timeout: 1.0)
    }
    
    func testTokenFetch() throws {
        let token = MockAuthToken(stringValue: "MockAuthToken")
        let userId = "TestUserID"
        
        authTokenStore.tokens[userId] = token
        
        XCTAssertEqual(authTokenStore.tokens[userId], token,
                       "Expected token to not exist in token store before storing it")
        
        let fetchToBeCalled = expectation(description: "Expected fetch method to be called")
        anyAuthTokenStore.fetchAuthToken(forUserId: userId) { result in
            switch result {
            case .success(let fetchedToken):
                XCTAssertEqual(fetchedToken, token, "Expected fetched token to equal the stored token")
                
            case .failure:
                XCTFail("Expected token fetch to not fail")
            }
            
            XCTAssertEqual(self.authTokenStore.tokens[userId], token,
                           "Expected token to still exist in token store after fetching it")
            fetchToBeCalled.fulfill()
        }
        
        wait(for: [fetchToBeCalled], timeout: 1.0)
    }
}
