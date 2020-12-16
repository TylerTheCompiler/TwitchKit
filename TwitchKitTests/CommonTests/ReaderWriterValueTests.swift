//
//  ReaderWriterValueTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/11/20.
//

import XCTest
@testable import TwitchKit

class ReaderWriterValueTests: XCTestCase {
    var value: ReaderWriterValue<Int>!
    
    override func setUp() {
        value = .init(wrappedValue: 0, Self.self, propertyName: "value")
    }
    
    override func tearDown() {
        value = nil
    }
    
    func test_modify_works() throws {
        let valueToBeRead = expectation(description: "Expected value to be read")
        let expectedFinalValue = 10000
        
        value.modify { innerValue in
            for _ in 0..<expectedFinalValue {
                innerValue += 1
            }
        }
        
        DispatchQueue.global().async {
            XCTAssertEqual(self.value.wrappedValue, expectedFinalValue,
                           "Expected value to have final value of \(expectedFinalValue)")
            valueToBeRead.fulfill()
        }
        
        wait(for: [valueToBeRead], timeout: 5.0)
    }
}
