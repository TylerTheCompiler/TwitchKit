//
//  KeychainAuthTokenStoringTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/12/20.
//

import XCTest
@testable import TwitchKit

class KeychainAuthTokenStoringTests: XCTestCase {
//    class MockKeychain: KeychainInteracting {
//        var getItemHandler: (([String: AnyObject]) -> (AnyObject?, OSStatus)) = { _ in (nil, errSecBadReq) }
//        var updateItemHandler: (([String: AnyObject], [String: AnyObject]) -> OSStatus) = { _, _ in errSecBadReq }
//        var addItemHandler: (([String: AnyObject]) -> OSStatus) = { _ in errSecBadReq }
//        var deleteItemHandler: (([String: AnyObject]) -> OSStatus) = { _ in errSecBadReq }
//
//        func getItem(with query: [String: AnyObject]) -> (result: AnyObject?, status: OSStatus) {
//            getItemHandler(query)
//        }
//
//        func updateItem(with query: [String: AnyObject], attributesToUpdate: [String: AnyObject]) -> OSStatus {
//            updateItemHandler(query, attributesToUpdate)
//        }
//
//        func addItem(with query: [String: AnyObject]) -> OSStatus {
//            addItemHandler(query)
//        }
//
//        func deleteItem(with query: [String: AnyObject]) -> OSStatus {
//            deleteItemHandler(query)
//        }
//    }
    
    class TestKeychainAuthTokenStore: KeychainAuthTokenStore<MockAuthToken> {
        override func keychainItemLabel(withUserId userId: String?) -> String? {
            return (super.keychainItemLabel(withUserId: userId) ?? "") + "This is the label. User ID: \(userId ?? "nil")"
        }
    }
    
    var keychainAuthTokenStore: TestKeychainAuthTokenStore!
    var mockKeychain: KeychainWrapper!
    var storeNotificationObserver: NSObjectProtocol?
    
    override func setUp() {
        mockKeychain = .init()
        keychainAuthTokenStore = .init(keyKind: "MockKeyKind", identifier: "MockIdentifier")
        keychainAuthTokenStore.keychainInteracting = mockKeychain
    }
    
    override func tearDown() {
        if let storeNotificationObserver = storeNotificationObserver {
            NotificationCenter.default.removeObserver(storeNotificationObserver)
        }
        
        keychainAuthTokenStore = nil
        mockKeychain = nil
        storeNotificationObserver = nil
    }
    
    // MARK: - Fetching
    
    func test_givenItemInKeychain_fetchTokenReturnsTokenData() {
        let fetchToComplete = expectation(description: "Expected fetch to complete")
        let mockAuthTokenString = "MockKeychainItemData"
        
        mockKeychain.getItem = { _, result in
            result?.pointee = Data("[\"\(mockAuthTokenString)\"]".utf8) as CFData
            return noErr
        }
        
        keychainAuthTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success(let authToken):
                XCTAssertEqual(authToken.stringValue, mockAuthTokenString)
                
            case .failure(let error):
                XCTFail("Expected to fetch auth token, got error: \(error)")
            }
            
            fetchToComplete.fulfill()
        }
        
        wait(for: [fetchToComplete], timeout: 1.0)
    }
    
    func test_givenNoItemInKeychain_fetchTokenReturnsError() {
        let fetchToComplete = expectation(description: "Expected fetch to complete")
        
        mockKeychain.getItem = { _, result in
            result?.pointee = nil
            return errSecItemNotFound
        }
        
        keychainAuthTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected fetch to fail")
                
            case .failure(KeychainAuthTokenStoreError.missingToken):
                break
                
            case .failure(let error):
                XCTFail("Expected \(KeychainAuthTokenStoreError.missingToken) error, got: \(error)")
            }
            
            fetchToComplete.fulfill()
        }
        
        wait(for: [fetchToComplete], timeout: 1.0)
    }
    
    func test_givenItemInKeychain_butUnhandledErrorOccurred_fetchTokenReturnsError() {
        let fetchToComplete = expectation(description: "Expected fetch to complete")
        let expectedStatus = errSecBadReq
        
        mockKeychain.getItem = { _, result in
            result?.pointee = nil
            return expectedStatus
        }
        
        keychainAuthTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected fetch to fail")
                
            case .failure(KeychainAuthTokenStoreError.unhandledError(status: expectedStatus)):
                break
                
            case .failure(let error):
                XCTFail("Expected \(KeychainAuthTokenStoreError.unhandledError(status: expectedStatus)) error, got: \(error)")
            }
            
            fetchToComplete.fulfill()
        }
        
        wait(for: [fetchToComplete], timeout: 1.0)
    }
    
    func test_givenItemInKeychain_butDataIsNotData_fetchTokenReturnsError() {
        let fetchToComplete = expectation(description: "Expected fetch to complete")
        
        mockKeychain.getItem = { _, result in
            result?.pointee = "This is a string, not a Data" as AnyObject
            return noErr
        }
        
        keychainAuthTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected fetch to fail")
                
            case .failure(KeychainAuthTokenStoreError.unexpectedItemData):
                break
                
            case .failure(let error):
                XCTFail("Expected \(KeychainAuthTokenStoreError.unexpectedItemData) error, got: \(error)")
            }
            
            fetchToComplete.fulfill()
        }
        
        wait(for: [fetchToComplete], timeout: 1.0)
    }
    
    func test_givenItemInKeychain_butDataCouldNotBeDecoded_fetchTokenReturnsError() {
        let fetchToComplete = expectation(description: "Expected fetch to complete")
        
        mockKeychain.getItem = { _, result in
            result?.pointee = Data("This is a Data, but it's not an array, so decoding should fail".utf8) as CFData
            return noErr
        }
        
        keychainAuthTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected fetch to fail")
                
            case .failure(DecodingError.dataCorrupted(_)):
                break
                
            case .failure(let error):
                XCTFail("Expected decoding error, got: \(error)")
            }
            
            fetchToComplete.fulfill()
        }
        
        wait(for: [fetchToComplete], timeout: 1.0)
    }
    
    func test_givenItemInKeychain_butDataIsEmptyArray_fetchTokenReturnsError() {
        let fetchToComplete = expectation(description: "Expected fetch to complete")
        
        mockKeychain.getItem = { _, result in
            result?.pointee = Data("[]".utf8) as CFData
            return noErr
        }
        
        keychainAuthTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected fetch to fail")
                
            case .failure(KeychainAuthTokenStoreError.emptyItemData):
                break
                
            case .failure(let error):
                XCTFail("Expected \(KeychainAuthTokenStoreError.emptyItemData) error, got: \(error)")
            }
            
            fetchToComplete.fulfill()
        }
        
        wait(for: [fetchToComplete], timeout: 1.0)
    }
    
    func test_givenMissingBundleId_fetchTokenReturnsError() {
        let fetchToComplete = expectation(description: "Expected fetch to complete")
        keychainAuthTokenStore.getBundleIdHandler = { nil }
        
        keychainAuthTokenStore.fetchAuthToken(forUserId: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected fetch to fail")
                
            case .failure(KeychainAuthTokenStoreError.missingBundleId):
                break
                
            case .failure(let error):
                XCTFail("Expected \(KeychainAuthTokenStoreError.missingBundleId) error, got: \(error)")
            }
            
            fetchToComplete.fulfill()
        }
        
        wait(for: [fetchToComplete], timeout: 1.0)
    }
    
    // MARK: - Storing
    
    func test_givenNoItemInKeychain_storeTokenAddsNewItemToKeychain() {
        let addItemToBeCalled = expectation(description: "Expected add item to be called")
        let storeToComplete = expectation(description: "Expected store to complete")
        let notifcationToBeReceived = expectation(description: "Expected notification to be received")
        let mockAuthTokenString = "MockAuthToken"
        let mockAuthToken = MockAuthToken(stringValue: mockAuthTokenString)
        let mockUserId = "MockUserId"
        let expectedData = Data("[\"\(mockAuthTokenString)\"]".utf8)
        let expectedLabel = "This is the label. User ID: \(mockUserId)"
        let expectedService = "com.apple.dt.xctest.tool.twitch-kit.MockIdentifier.MockKeyKind"
        
        storeNotificationObserver = NotificationCenter.default.addObserver(
            forName: .keychainAuthTokenStoreDidStoreAuthToken,
            object: keychainAuthTokenStore,
            queue: nil
        ) { notification in
            XCTAssertEqual(notification.userInfo?[keychainAuthTokenStoreAuthTokenUserInfoKey] as? MockAuthToken,
                           mockAuthToken,
                           "Expected notification to contain auth token")
            XCTAssertEqual(notification.userInfo?[keychainAuthTokenStoreUserIdUserInfoKey] as? String,
                           mockUserId,
                           "Expected notification to contain user ID")
            notifcationToBeReceived.fulfill()
        }
        
        mockKeychain.getItem = { _, result in
            result?.pointee = nil
            return errSecItemNotFound
        }
        
        mockKeychain.addItem = { query, _ in
            let query = query as NSDictionary
            XCTAssertEqual(query[kSecAttrAccount as String] as? String, mockUserId,
                           "Expected add item query to contain user ID for the account")
            XCTAssertEqual(query[kSecAttrService as String] as? String, expectedService,
                           "Expected add item query to contain the correct value for the service")
            XCTAssertEqual(query[kSecAttrLabel as String] as? String, expectedLabel,
                           "Expected add item query to contain the expected label")
            XCTAssertEqual(query[kSecValueData as String] as? Data, expectedData,
                           "Expected add item query to contain the auth token data")
            addItemToBeCalled.fulfill()
            return noErr
        }
        
        keychainAuthTokenStore.store(authToken: mockAuthToken, forUserId: mockUserId) { error in
            XCTAssertNil(error, "Expected error to be nil")
            storeToComplete.fulfill()
        }
        
        wait(for: [addItemToBeCalled, notifcationToBeReceived, storeToComplete], timeout: 1.0, enforceOrder: true)
    }
    
    func test_givenNoItemInKeychain_butAddItemFails_storeTokenReturnsError() {
        let addItemToBeCalled = expectation(description: "Expected add item to be called")
        let storeToComplete = expectation(description: "Expected store to complete")
        let mockAuthTokenString = "MockAuthToken"
        let mockAuthToken = MockAuthToken(stringValue: mockAuthTokenString)
        let mockUserId = "MockUserId"
        let expectedData = Data("[\"\(mockAuthTokenString)\"]".utf8)
        let expectedError = errSecBadReq
        let expectedLabel = "This is the label. User ID: \(mockUserId)"
        let expectedService = "com.apple.dt.xctest.tool.twitch-kit.MockIdentifier.MockKeyKind"
        
        storeNotificationObserver = NotificationCenter.default.addObserver(
            forName: .keychainAuthTokenStoreDidStoreAuthToken,
            object: keychainAuthTokenStore,
            queue: nil
        ) { _ in
            XCTFail("Expected did store auth token notification to not be posted")
        }
        
        mockKeychain.getItem = { _, result in
            result?.pointee = nil
            return errSecItemNotFound
        }
        
        mockKeychain.addItem = { query, _ in
            let query = query as NSDictionary
            XCTAssertEqual(query[kSecAttrAccount as String] as? String, mockUserId,
                           "Expected add item query to contain user ID for the account")
            XCTAssertEqual(query[kSecAttrService as String] as? String, expectedService,
                           "Expected add item query to contain the correct value for the service")
            XCTAssertEqual(query[kSecAttrLabel as String] as? String, expectedLabel,
                           "Expected add item query to contain the expected label")
            XCTAssertEqual(query[kSecValueData as String] as? Data, expectedData,
                           "Expected add item query to contain the auth token data")
            addItemToBeCalled.fulfill()
            return expectedError
        }
        
        keychainAuthTokenStore.store(authToken: mockAuthToken, forUserId: mockUserId) { error in
            defer { storeToComplete.fulfill() }
            guard let error = error else {
                XCTFail("Expected \(KeychainAuthTokenStoreError.unhandledError(status: expectedError)) error")
                return
            }
            
            switch error {
            case KeychainAuthTokenStoreError.unhandledError(status: expectedError):
                break
                
            default:
                XCTFail("Expected \(KeychainAuthTokenStoreError.unhandledError(status: expectedError)) error, got: \(error as Any)")
            }
        }
        
        wait(for: [addItemToBeCalled, storeToComplete], timeout: 1.0, enforceOrder: true)
    }
    
    func test_givenItemAlreadyInKeychain_storeTokenUpdatesExistingItemToKeychain() {
        let updateItemToBeCalled = expectation(description: "Expected update item to be called")
        let storeToComplete = expectation(description: "Expected store to complete")
        let notifcationToBeReceived = expectation(description: "Expected notification to be received")
        let mockAuthTokenString = "MockAuthToken"
        let mockAuthToken = MockAuthToken(stringValue: mockAuthTokenString)
        let mockUserId = "MockUserId"
        let expectedData = Data("[\"\(mockAuthTokenString)\"]".utf8)
        let expectedLabel = "This is the label. User ID: \(mockUserId)"
        let expectedService = "com.apple.dt.xctest.tool.twitch-kit.MockIdentifier.MockKeyKind"
        
        storeNotificationObserver = NotificationCenter.default.addObserver(
            forName: .keychainAuthTokenStoreDidStoreAuthToken,
            object: keychainAuthTokenStore,
            queue: nil
        ) { notification in
            XCTAssertEqual(notification.userInfo?[keychainAuthTokenStoreAuthTokenUserInfoKey] as? MockAuthToken,
                           mockAuthToken,
                           "Expected notification to contain auth token")
            XCTAssertEqual(notification.userInfo?[keychainAuthTokenStoreUserIdUserInfoKey] as? String,
                           mockUserId,
                           "Expected notification to contain user ID")
            notifcationToBeReceived.fulfill()
        }
        
        mockKeychain.getItem = { _, result in
            result?.pointee = nil
            return noErr
        }
        
        mockKeychain.updateItem = { query, attributesToUpdate in
            let query = query as NSDictionary
            let attributesToUpdate = attributesToUpdate as NSDictionary
            XCTAssertEqual(query[kSecAttrAccount as String] as? String, mockUserId,
                           "Expected update item query to contain user ID for the account")
            XCTAssertEqual(query[kSecAttrService as String] as? String, expectedService,
                           "Expected add item query to contain the correct value for the service")
            XCTAssertEqual(attributesToUpdate[kSecAttrLabel as String] as? String, expectedLabel,
                           "Expected update item attributes to contain the expected label")
            XCTAssertEqual(attributesToUpdate[kSecValueData as String] as? Data, expectedData,
                           "Expected update item attributes to contain the auth token data")
            updateItemToBeCalled.fulfill()
            return noErr
        }
        
        keychainAuthTokenStore.store(authToken: mockAuthToken, forUserId: mockUserId) { error in
            XCTAssertNil(error, "Expected error to be nil")
            storeToComplete.fulfill()
        }
        
        wait(for: [updateItemToBeCalled, notifcationToBeReceived, storeToComplete], timeout: 1.0, enforceOrder: true)
    }
    
    func test_givenItemAlreadyInKeychain_butUpdateItemFails_storeTokenReturnsError() {
        let updateItemToBeCalled = expectation(description: "Expected update item to be called")
        let storeToComplete = expectation(description: "Expected store to complete")
        let mockAuthTokenString = "MockAuthToken"
        let mockAuthToken = MockAuthToken(stringValue: mockAuthTokenString)
        let mockUserId = "MockUserId"
        let expectedData = Data("[\"\(mockAuthTokenString)\"]".utf8)
        let expectedLabel = "This is the label. User ID: \(mockUserId)"
        let expectedService = "com.apple.dt.xctest.tool.twitch-kit.MockIdentifier.MockKeyKind"
        let expectedError = errSecBadReq
        
        storeNotificationObserver = NotificationCenter.default.addObserver(
            forName: .keychainAuthTokenStoreDidStoreAuthToken,
            object: keychainAuthTokenStore,
            queue: nil
        ) { _ in
            XCTFail("Expected did store auth token notification to not be posted")
        }
        
        mockKeychain.getItem = { _, result in
            result?.pointee = nil
            return noErr
        }
        
        mockKeychain.updateItem = { query, attributesToUpdate in
            let query = query as NSDictionary
            let attributesToUpdate = attributesToUpdate as NSDictionary
            XCTAssertEqual(query[kSecAttrAccount as String] as? String, mockUserId,
                           "Expected update item query to contain user ID for the account")
            XCTAssertEqual(query[kSecAttrService as String] as? String, expectedService,
                           "Expected add item query to contain the correct value for the service")
            XCTAssertEqual(attributesToUpdate[kSecAttrLabel as String] as? String, expectedLabel,
                           "Expected update item attributes to contain the expected label")
            XCTAssertEqual(attributesToUpdate[kSecValueData as String] as? Data, expectedData,
                           "Expected update item attributes to contain the auth token data")
            updateItemToBeCalled.fulfill()
            return expectedError
        }
        
        keychainAuthTokenStore.store(authToken: mockAuthToken, forUserId: mockUserId) { error in
            defer { storeToComplete.fulfill() }
            guard let error = error else {
                XCTFail("Expected \(KeychainAuthTokenStoreError.unhandledError(status: expectedError)) error")
                return
            }
            
            switch error {
            case KeychainAuthTokenStoreError.unhandledError(status: expectedError):
                break
                
            default:
                XCTFail("Expected \(KeychainAuthTokenStoreError.unhandledError(status: expectedError)) error, got: \(error as Any)")
            }
        }
        
        wait(for: [updateItemToBeCalled, storeToComplete], timeout: 1.0, enforceOrder: true)
    }
    
    func test_givenItemAlreadyInKeychain_removeTokenDeletesExistingItemFromKeychain() {
        let deleteItemToBeCalled = expectation(description: "Expected delete item to be called")
        let storeToComplete = expectation(description: "Expected store to complete")
        let notifcationToBeReceived = expectation(description: "Expected notification to be received")
        let mockUserId = "MockUserId"
        let expectedService = "com.apple.dt.xctest.tool.twitch-kit.MockIdentifier.MockKeyKind"
        
        storeNotificationObserver = NotificationCenter.default.addObserver(
            forName: .keychainAuthTokenStoreDidStoreAuthToken,
            object: keychainAuthTokenStore,
            queue: nil
        ) { notification in
            XCTAssertEqual(notification.userInfo?[keychainAuthTokenStoreAuthTokenUserInfoKey] as? MockAuthToken,
                           nil,
                           "Expected notification to contain nil auth token")
            XCTAssertEqual(notification.userInfo?[keychainAuthTokenStoreUserIdUserInfoKey] as? String,
                           mockUserId,
                           "Expected notification to contain user ID")
            notifcationToBeReceived.fulfill()
        }
        
        mockKeychain.deleteItem = { query in
            let query = query as NSDictionary
            XCTAssertEqual(query[kSecAttrAccount as String] as? String, mockUserId,
                           "Expected update item query to contain user ID for the account")
            XCTAssertEqual(query[kSecAttrService as String] as? String, expectedService,
                           "Expected add item query to contain the correct value for the service")
            deleteItemToBeCalled.fulfill()
            return noErr
        }
        
        keychainAuthTokenStore.removeAuthToken(forUserId: mockUserId) { error in
            XCTAssertNil(error, "Expected error to be nil")
            storeToComplete.fulfill()
        }
        
        wait(for: [deleteItemToBeCalled, notifcationToBeReceived, storeToComplete], timeout: 1.0, enforceOrder: true)
    }
    
    func test_givenItemNotInKeychain_removeTokenReturnsError() {
        let deleteItemToBeCalled = expectation(description: "Expected delete item to be called")
        let storeToComplete = expectation(description: "Expected store to complete")
        let mockUserId = "MockUserId"
        let expectedService = "com.apple.dt.xctest.tool.twitch-kit.MockIdentifier.MockKeyKind"
        let expectedError = errSecItemNotFound
        
        storeNotificationObserver = NotificationCenter.default.addObserver(
            forName: .keychainAuthTokenStoreDidStoreAuthToken,
            object: keychainAuthTokenStore,
            queue: nil
        ) { notification in
            XCTFail("Expected did store auth token notification to not be posted")
        }
        
        mockKeychain.deleteItem = { query in
            let query = query as NSDictionary
            XCTAssertEqual(query[kSecAttrAccount as String] as? String, mockUserId,
                           "Expected update item query to contain user ID for the account")
            XCTAssertEqual(query[kSecAttrService as String] as? String, expectedService,
                           "Expected add item query to contain the correct value for the service")
            deleteItemToBeCalled.fulfill()
            return expectedError
        }
        
        keychainAuthTokenStore.removeAuthToken(forUserId: mockUserId) { error in
            defer { storeToComplete.fulfill() }
            guard let error = error else {
                XCTFail("Expected \(KeychainAuthTokenStoreError.unhandledError(status: expectedError)) error")
                return
            }
            
            switch error {
            case KeychainAuthTokenStoreError.unhandledError(status: expectedError):
                break
                
            default:
                XCTFail("Expected \(KeychainAuthTokenStoreError.unhandledError(status: expectedError)) error, got: \(error as Any)")
            }
        }
        
        wait(for: [deleteItemToBeCalled, storeToComplete], timeout: 1.0, enforceOrder: true)
    }
    
    func test_givenMissingBundleId_storeTokenReturnsError() {
        let storeToComplete = expectation(description: "Expected store to complete")
        let mockAuthToken = MockAuthToken(stringValue: "MockAuthToken")
        
        keychainAuthTokenStore.getBundleIdHandler = { nil }
        
        keychainAuthTokenStore.store(authToken: mockAuthToken, forUserId: nil) { error in
            defer { storeToComplete.fulfill() }
            guard let error = error else {
                XCTFail("Expected \(KeychainAuthTokenStoreError.missingBundleId) error")
                return
            }
            
            switch error {
            case KeychainAuthTokenStoreError.missingBundleId:
                break
                
            default:
                XCTFail("Expected \(KeychainAuthTokenStoreError.missingBundleId) error, got: \(error as Any)")
            }
        }
        
        wait(for: [storeToComplete], timeout: 1.0)
    }
}
