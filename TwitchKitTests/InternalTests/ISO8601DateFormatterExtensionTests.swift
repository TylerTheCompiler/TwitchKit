//
//  ISO8601DateFormatterExtensionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

class ISO8601DateFormatterExtensionTests: XCTestCase {
    func test_internetDateFormatter_hasCorrectFormatOptions() throws {
        XCTAssertEqual(ISO8601DateFormatter.internetDateFormatter.formatOptions, .withInternetDateTime,
                       "Expected internet date formatter to have internet date time format option")
    }
    
    func test_internetDateWithFractionalSecondsFormatter_hasCorrectFormatOptions() throws {
        XCTAssertEqual(ISO8601DateFormatter.internetDateWithFractionalSecondsFormatter.formatOptions,
                       [.withInternetDateTime, .withFractionalSeconds],
                       "Expected internet date with fractional seconds formatter to have internet date time and fractional seconds format options")
    }
}
