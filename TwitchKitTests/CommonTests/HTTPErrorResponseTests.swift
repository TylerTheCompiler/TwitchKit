//
//  HTTPErrorResponseTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/11/20.
//

import XCTest
@testable import TwitchKit

class HTTPErrorResponseTests: XCTestCase {
    func test_failureInitializer_works() throws {
        let expectedError = NSError(domain: "TestError", code: 0, userInfo: nil)
        let expectedHTTPURLResponse = HTTPURLResponse(url: URL(string: "mockscheme://mockhost")!,
                                                      statusCode: 123,
                                                      httpVersion: nil,
                                                      headerFields: nil)
        
        let response = HTTPErrorResponse(expectedError, expectedHTTPURLResponse)
        
        XCTAssertEqual(response.httpURLResponse, expectedHTTPURLResponse,
                       "Expected response's httpURLResponse to be equal to expectedHTTPURLResponse")
        XCTAssertEqual(response.error as NSError?, expectedError,
                       "Expected result error to be equal to expected error")
    }
}
