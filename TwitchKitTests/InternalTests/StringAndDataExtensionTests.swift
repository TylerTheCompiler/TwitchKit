//
//  StringAndDataExtensionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

class StringAndDataExtensionTests: XCTestCase {
    func test_base64URLDecodedData_isEqualToExpectedValue() throws {
        let encodedString = "Pj8-Pz4_Pj8_Pw"
        let expectedData = Data(">?>?>?>???".utf8)
        
        XCTAssertEqual(encodedString.base64URLDecodedData, expectedData,
                       "Expected base64 URL decoded data to match expected value")
    }
    
    func test_base64URLDecodedString_isEqualToExpectedValue() throws {
        let encodedString = "Pj8-Pz4_Pj8_Pw"
        let expectedString = ">?>?>?>???"
        
        XCTAssertEqual(encodedString.base64URLDecoded, expectedString,
                       "Expected base64 URL decoded string to match expected value")
    }
    
    func test_base64URLEncodedString_isEqualToExpectedValue() throws {
        let decodedData = Data(">?>?>?>???".utf8)
        let expectedString = "Pj8-Pz4_Pj8_Pw"
        
        XCTAssertEqual(decodedData.base64URLEncodedString, expectedString,
                       "Expected base64 URL encoded string to match expected value")
    }
    
    func test_escapedIRCMessageTagValue_isEqualToExpectedValue() throws {
        let unescapedString = "This is a message. \\; \r\n"
        let expectedString = "This\\sis\\sa\\smessage.\\s\\\\\\:\\s\\r\\n"
        
        XCTAssertEqual(unescapedString.escapedIRCMessageTagValue, expectedString,
                       "Expected escaped IRC message string to match the expected string")
    }
    
    func test_unescapedIRCMessageTagValue_isEqualToExpectedValue() throws {
        let escapedString = "This\\sis\\sa\\smessage.\\s\\\\\\:\\s\\r\\n"
        let expectedString = "This is a message. \\; \r\n"
        
        XCTAssertEqual(escapedString.unescapedIRCMessageTagValue, expectedString,
                       "Expected unescaped IRC message string to match the expected string")
    }
}
