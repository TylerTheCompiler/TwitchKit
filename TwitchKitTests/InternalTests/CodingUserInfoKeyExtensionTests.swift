//
//  CodingUserInfoKeyExtensionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

class CodingUserInfoKeyExtensionTests: XCTestCase {
    func test_initWithRawValue_createsNewCodingUserInfoKey() throws {
        let expectedRawValue = "MockCodingUserInfoKeyRawValue"
        let codingUserInfoKey = CodingUserInfoKey.init("MockCodingUserInfoKeyRawValue")
        XCTAssertEqual(codingUserInfoKey.rawValue, expectedRawValue,
                       "Expected coding user info key rawValue to be equal to expected value")
    }
}
