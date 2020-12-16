//
//  HTTPResponseTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/11/20.
//

import XCTest
@testable import TwitchKit

class HTTPResponseTests: XCTestCase {
    func test_designatedInitializer_works() throws {
        let expectedString = "ExpectedString"
        let expectedHTTPURLResponse = HTTPURLResponse(url: URL(string: "mockscheme://mockhost")!,
                                                      statusCode: 123,
                                                      httpVersion: nil,
                                                      headerFields: nil)
        
        let response = HTTPResponse(Result<String, Error> { expectedString },
                                    expectedHTTPURLResponse)
        
        XCTAssertEqual(response.httpURLResponse, expectedHTTPURLResponse,
                       "Expected response's httpURLResponse to be equal to expectedHTTPURLResponse")
        
        switch response.result {
        case .success(let string):
            XCTAssertEqual(string, expectedString, "Expected result success value to be equal to expected value")
            
        case .failure(let error):
            XCTFail("Expected to not receive error, but got: \(error)")
        }
    }
    
    func test_successInitializer_works() throws {
        let expectedString = "ExpectedString"
        let expectedHTTPURLResponse = HTTPURLResponse(url: URL(string: "mockscheme://mockhost")!,
                                                      statusCode: 123,
                                                      httpVersion: nil,
                                                      headerFields: nil)
        
        let response = HTTPResponse<String, Error>(expectedString, expectedHTTPURLResponse)
        
        XCTAssertEqual(response.httpURLResponse, expectedHTTPURLResponse,
                       "Expected response's httpURLResponse to be equal to expectedHTTPURLResponse")
        
        switch response.result {
        case .success(let string):
            XCTAssertEqual(string, expectedString, "Expected result success value to be equal to expected value")
            
        case .failure(let error):
            XCTFail("Expected to not receive error, but got: \(error)")
        }
    }
    
    func test_failureInitializer_works() throws {
        let expectedError = NSError(domain: "TestError", code: 0, userInfo: nil)
        let expectedHTTPURLResponse = HTTPURLResponse(url: URL(string: "mockscheme://mockhost")!,
                                                      statusCode: 123,
                                                      httpVersion: nil,
                                                      headerFields: nil)
        
        let response = HTTPResponse<String, Error>(expectedError, expectedHTTPURLResponse)
        
        XCTAssertEqual(response.httpURLResponse, expectedHTTPURLResponse,
                       "Expected response's httpURLResponse to be equal to expectedHTTPURLResponse")
        
        switch response.result {
        case .success:
            XCTFail("Expected failure response result")
            
        case .failure(let error):
            XCTAssertEqual(error as NSError, expectedError, "Expected result error to be equal to expected error")
        }
    }
}
