//
//  AuthCodeScopeAndClaimTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/11/20.
//

import XCTest
@testable import TwitchKit

class AuthCodeScopeAndClaimTests: XCTestCase {
    func test_authCode_stringInitializer() {
        let rawValue = "MockAuthCode"
        XCTAssertEqual(AuthCode(rawValue: rawValue).rawValue, rawValue, "Incorrect string value")
    }
    
    func test_scopeDescription_isEqualToRawValue() {
        for scope in Scope.allCases {
            XCTAssertEqual(scope.description, scope.rawValue, "Incorrect description")
        }
    }
    
    func test_claimDescription_isEqualToRawValue() {
        for claim in Claim.allCases {
            XCTAssertEqual(claim.description, claim.rawValue, "Incorrect description")
        }
    }
}
