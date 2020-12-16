//
//  KeychainAuthTokenStoreSubclassTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/12/20.
//

import XCTest
@testable import TwitchKit

class KeychainAuthTokenStoreSubclassTests: XCTestCase {
    func test_userAccessTokenStoreInitializer_storesCorrectProperties_and_labelIsCorrect() {
        let expectedSynchronizesOveriCloudValue = true
        let expectedIdentifier = "MockIdentifier"
        let mockUserId = "MockUserId"
        let expectedLabel = "Twitch User Access Token (User ID: \(mockUserId))"
        
        let tokenStore = KeychainUserAccessTokenStore(synchronizesOveriCloud: expectedSynchronizesOveriCloudValue,
                                                      identifier: expectedIdentifier)
        XCTAssertEqual(tokenStore.identifier, expectedIdentifier, "Incorrect identifier")
        XCTAssertEqual(tokenStore.synchronizesOveriCloud, expectedSynchronizesOveriCloudValue,
                       "Incorrect synchronizesOveriCloud value")
        XCTAssertEqual(tokenStore.keychainItemLabel(withUserId: mockUserId), expectedLabel, "Incorrect label")
    }
    
    func test_givenNilUserId_userAccessTokenStoreInitializer_storesCorrectProperties_and_labelIsCorrect() {
        let expectedSynchronizesOveriCloudValue = true
        let expectedIdentifier = "MockIdentifier"
        let mockUserId: String? = nil
        let expectedLabel = "Twitch User Access Token (User ID: <unknown>)"
        
        let tokenStore = KeychainUserAccessTokenStore(synchronizesOveriCloud: expectedSynchronizesOveriCloudValue,
                                                      identifier: expectedIdentifier)
        XCTAssertEqual(tokenStore.identifier, expectedIdentifier, "Incorrect identifier")
        XCTAssertEqual(tokenStore.synchronizesOveriCloud, expectedSynchronizesOveriCloudValue,
                       "Incorrect synchronizesOveriCloud value")
        XCTAssertEqual(tokenStore.keychainItemLabel(withUserId: mockUserId), expectedLabel, "Incorrect label")
    }
    
    func test_refreshTokenStoreInitializer_storesCorrectProperties_and_labelIsCorrect() {
        let expectedSynchronizesOveriCloudValue = false
        let expectedIdentifier = "MockIdentifier"
        let mockUserId = "MockUserId"
        let expectedLabel = "Twitch Refresh Token (User ID: \(mockUserId))"
        
        let tokenStore = KeychainRefreshTokenStore(identifier: expectedIdentifier)
        XCTAssertEqual(tokenStore.identifier, expectedIdentifier, "Incorrect identifier")
        XCTAssertEqual(tokenStore.synchronizesOveriCloud, expectedSynchronizesOveriCloudValue,
                       "Incorrect synchronizesOveriCloud value")
        XCTAssertEqual(tokenStore.keychainItemLabel(withUserId: mockUserId), expectedLabel, "Incorrect label")
    }
    
    func test_givenNilUserId_refreshTokenStoreInitializer_storesCorrectProperties_and_labelIsCorrect() {
        let expectedSynchronizesOveriCloudValue = false
        let expectedIdentifier = "MockIdentifier"
        let mockUserId: String? = nil
        let expectedLabel = "Twitch Refresh Token (User ID: <unknown>)"
        
        let tokenStore = KeychainRefreshTokenStore(identifier: expectedIdentifier)
        XCTAssertEqual(tokenStore.identifier, expectedIdentifier, "Incorrect identifier")
        XCTAssertEqual(tokenStore.synchronizesOveriCloud, expectedSynchronizesOveriCloudValue,
                       "Incorrect synchronizesOveriCloud value")
        XCTAssertEqual(tokenStore.keychainItemLabel(withUserId: mockUserId), expectedLabel, "Incorrect label")
    }
    
    func test_appAccessTokenStoreInitializer_storesCorrectProperties_and_labelIsCorrect() {
        let expectedSynchronizesOveriCloudValue = false
        let expectedIdentifier = "MockIdentifier"
        let expectedLabel = "Twitch App Access Token"
        
        let tokenStore = KeychainAppAccessTokenStore(identifier: expectedIdentifier)
        XCTAssertEqual(tokenStore.identifier, expectedIdentifier, "Incorrect identifier")
        XCTAssertEqual(tokenStore.synchronizesOveriCloud, expectedSynchronizesOveriCloudValue,
                       "Incorrect synchronizesOveriCloud value")
        XCTAssertEqual(tokenStore.keychainItemLabel(withUserId: nil), expectedLabel, "Incorrect label")
    }
}
