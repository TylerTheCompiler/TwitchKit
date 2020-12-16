//
//  RefreshTokenTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/11/20.
//

import XCTest
@testable import TwitchKit

class RefreshTokenTests: XCTestCase {
    func test_refreshToken_stringInitializer() throws {
        let rawValue = "MockRefreshToken"
        XCTAssertEqual(RefreshToken(rawValue: rawValue).rawValue, rawValue,
                       "Incorrect raw value")
    }
    
    func test_refreshToken_decodesFromStringValue() throws {
        let refreshTokenString = "MockRefreshToken"
        let data = try JSONEncoder().encode([refreshTokenString])
        let refreshTokens = try JSONDecoder().decode([RefreshToken].self, from: data)
        XCTAssertEqual(refreshTokens.first?.rawValue, refreshTokenString, "Incorrect string value")
    }
    
    func test_refreshToken_encodesToStringValue() throws {
        let refreshTokenString = "MockAccessToken"
        let refreshToken = RefreshToken(rawValue: refreshTokenString)
        let data = try JSONEncoder().encode(refreshToken)
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, "\"\(refreshTokenString)\"", "Incorrect string value")
    }
}
