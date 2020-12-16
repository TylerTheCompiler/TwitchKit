//
//  OptionalExtensionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

class OptionalExtensionTests: XCTestCase {
    func test_givenNilValue_isEmptyReturnsTrue() throws {
        let array: [String]? = nil
        XCTAssertTrue(array.isEmpty, "Expected nil optional array to be empty")
    }
}
