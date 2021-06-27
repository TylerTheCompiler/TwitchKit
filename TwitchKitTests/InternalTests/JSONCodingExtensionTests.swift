//
//  JSONCodingExtensionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

class JSONCodingExtensionTests: XCTestCase {
    func test_snakeCaseToCamelCaseDecoder_hasCorrectKeyDecodingStrategy() throws {
        switch JSONDecoder.snakeCaseToCamelCase.keyDecodingStrategy {
        case .convertFromSnakeCase: break
        default: XCTFail("Expected snakeCaseToCamelCase JSONDecoder to have convertFromSnakeCase keyDecodingStrategy")
        }
    }
    
    func test_camelCaseToSnakeCaseEncoder_hasCorrectKeyEncodingStrategy() throws {
        switch JSONEncoder.camelCaseToSnakeCase.keyEncodingStrategy {
        case .convertToSnakeCase: break
        default: XCTFail("Expected camelCaseToSnakeCase JSONEncoder to have convertToSnakeCase keyEncodingStrategy")
        }
    }
    
    func test_decodeNilData_decodesAsEmptyData() throws {
        do {
            _ = try JSONDecoder().decode(String.self, from: nil)
            XCTFail("Expected error to be thrown")
        } catch DecodingError.dataCorrupted(let context) {
            XCTAssertTrue(context.codingPath.isEmpty, "Expected codingPath to be empty")
            XCTAssertEqual(context.debugDescription, "The given data was not valid JSON.",
                           "Incorrect debugDescription")
            
            let expectedUnderlyingError = NSError(
                domain: NSCocoaErrorDomain,
                code: NSPropertyListReadCorruptError,
                userInfo: nil
            )
            
            let underlyingError = context.underlyingError as NSError?
            XCTAssertEqual(expectedUnderlyingError.domain, underlyingError?.domain,
                           "Incorrect underlying error domain.")
            XCTAssertEqual(expectedUnderlyingError.code, underlyingError?.code,
                           "Incorrect underlying error code.")
        } catch {
            XCTFail("Expected DecodingError.dataCorrupted, got: \(error)")
        }
    }
}
