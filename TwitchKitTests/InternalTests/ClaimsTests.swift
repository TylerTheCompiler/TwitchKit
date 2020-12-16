//
//  ClaimsTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

class ClaimsTests: XCTestCase {
    func testEmptyClaimsFailsInitializer() throws {
        XCTAssertNil(Claims(idTokenClaims: [], userinfoClaims: []), "Expected claims to be nil")
    }
    
    func testEncodesProperly() throws {
        let claims = Claims(idTokenClaims: .all, userinfoClaims: .all)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let claimsData = try encoder.encode(claims)
        
        guard let claimsDict = try JSONSerialization.jsonObject(with: claimsData) as? [String: [String: String?]] else {
            XCTFail("Expected claims to encode into a dictionary")
            return
        }
        
        let expectedClaims: [String: String?] = [
            "email": nil,
            "email_verified": nil,
            "picture": nil,
            "preferred_username": nil,
            "updated_at": nil
        ]
        
        XCTAssertEqual(claimsDict["id_token"], expectedClaims,
                       "Expected id_token claims to be equal to expected claims")
        
        XCTAssertEqual(claimsDict["userinfo"], expectedClaims,
                       "Expected id_token claims to be equal to expected claims")
    }
}
