//
//  URLComponentsExtensionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

class URLComponentsExtensionTests: XCTestCase {
    var components: URLComponents!
    
    override func setUp() {
        components = URLComponents()
        components.queryItems = [
            .init(name: "apple", value: "one"),
            .init(name: "orange", value: "two"),
            .init(name: "banana", value: "three"),
            .init(name: "orange", value: "four")
        ]
    }
    
    override func tearDown() {
        components = nil
    }
    
    // MARK: - With Non-nil queryItems
    
    func test_firstQueryValue_returnsValueOfFirstMatchingQueryItem() throws {
        XCTAssertEqual(components.firstQueryValue(for: "orange"), "two",
                       "Expected the first value for \"orange\" to be \"two\"")
    }
    
    func test_queryValues_returnsValuesOfAllMatchingQueryItems() throws {
        XCTAssertEqual(components.queryValues(for: "orange"), ["two", "four"],
                       "Expected the values for \"orange\" to be [\"two\", \"four\"]")
    }
    
    func test_setQueryValue_removesAllMatchingQueryItems_andAppendsNewQueryItem() throws {
        let expectedQueryItems: [URLQueryItem] = [
            .init(name: "apple", value: "one"),
            .init(name: "banana", value: "three"),
            .init(name: "orange", value: "five")
        ]
        
        components.setQueryValue("five", for: "orange")
        
        XCTAssertEqual(components.queryItems, expectedQueryItems, "Expected the query items to be updated")
    }
    
    func test_setQueryValues_removesAllMatchingQueryItems_andAppendsNewQueryItems() throws {
        let expectedQueryItems: [URLQueryItem] = [
            .init(name: "apple", value: "one"),
            .init(name: "banana", value: "three"),
            .init(name: "orange", value: "five"),
            .init(name: "orange", value: "six"),
            .init(name: "orange", value: "seven")
        ]
        
        components.setQueryValues(["five", "six", "seven"], for: "orange")
        
        XCTAssertEqual(components.queryItems, expectedQueryItems, "Expected the query items to be updated")
    }
    
    func test_addQueryValue_appendsNewQueryItem() throws {
        let expectedQueryItems: [URLQueryItem] = [
            .init(name: "apple", value: "one"),
            .init(name: "orange", value: "two"),
            .init(name: "banana", value: "three"),
            .init(name: "orange", value: "four"),
            .init(name: "orange", value: "five")
        ]
        
        components.addQueryValue("five", for: "orange")
        
        XCTAssertEqual(components.queryItems, expectedQueryItems, "Expected the new query item to be appended")
    }
    
    func test_addQueryValues_appendsNewQueryItems() throws {
        let expectedQueryItems: [URLQueryItem] = [
            .init(name: "apple", value: "one"),
            .init(name: "orange", value: "two"),
            .init(name: "banana", value: "three"),
            .init(name: "orange", value: "four"),
            .init(name: "orange", value: "five"),
            .init(name: "orange", value: "six"),
            .init(name: "orange", value: "seven")
        ]
        
        components.addQueryValues(["five", "six", "seven"], for: "orange")
        
        XCTAssertEqual(components.queryItems, expectedQueryItems, "Expected the new query items to be appended")
    }
    
    // MARK: - With nil queryItems
    
    func test_givenNilQueryItems_queryValues_returnsValuesOfAllMatchingQueryItems() throws {
        components.query = nil
        XCTAssertEqual(components.queryValues(for: "orange"), [], "Expected the values to be an empty array.")
    }
    
    func test_givenNilQueryItems_setQueryValue_removesAllMatchingQueryItems_andAppendsNewQueryItem() throws {
        components.query = nil
        let expectedQueryItems: [URLQueryItem] = [
            .init(name: "orange", value: "five")
        ]
        
        components.setQueryValue("five", for: "orange")
        
        XCTAssertEqual(components.queryItems, expectedQueryItems, "Expected the query items to be updated")
    }
    
    func test_givenNilQueryItems_setQueryValues_removesAllMatchingQueryItems_andAppendsNewQueryItems() throws {
        components.query = nil
        let expectedQueryItems: [URLQueryItem] = [
            .init(name: "orange", value: "five"),
            .init(name: "orange", value: "six"),
            .init(name: "orange", value: "seven")
        ]
        
        components.setQueryValues(["five", "six", "seven"], for: "orange")
        
        XCTAssertEqual(components.queryItems, expectedQueryItems, "Expected the query items to be updated")
    }
    
    func test_givenNilQueryItems_addQueryValue_appendsNewQueryItem() throws {
        components.query = nil
        let expectedQueryItems: [URLQueryItem] = [
            .init(name: "orange", value: "five")
        ]
        
        components.addQueryValue("five", for: "orange")
        
        XCTAssertEqual(components.queryItems, expectedQueryItems, "Expected the new query item to be appended")
    }
    
    func test_givenNilQueryItems_addQueryValues_appendsNewQueryItems() throws {
        components.query = nil
        let expectedQueryItems: [URLQueryItem] = [
            .init(name: "orange", value: "five"),
            .init(name: "orange", value: "six"),
            .init(name: "orange", value: "seven")
        ]
        
        components.addQueryValues(["five", "six", "seven"], for: "orange")
        
        XCTAssertEqual(components.queryItems, expectedQueryItems, "Expected the new query items to be appended")
    }
    
    // MARK: - URL Request
    
    func test_urlRequest_returnsCorrectValue() throws {
        components.scheme = "https"
        components.host = "example.com"
        components.path = "/path/to/something"
        
        let expectedURLRequest = URLRequest(url: components.url!)
        
        XCTAssertEqual(components.urlRequest, expectedURLRequest,
                       "Expected URL components URL request to match expected URL request")
    }
}
