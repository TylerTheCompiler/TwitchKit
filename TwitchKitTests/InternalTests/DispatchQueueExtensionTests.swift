//
//  DispatchQueueExtensionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

class DispatchQueueExtensionTests: XCTestCase {
    func test_initForType_createsNewDispatchQueueWithCorrectValues() throws {
        let queue = DispatchQueue(for: Self.self, name: "MockQueue", qos: .userInitiated)
        
        XCTAssertEqual(queue.label, "com.apple.dt.xctest.tool.TwitchKit.DispatchQueueExtensionTests.MockQueue",
                       "Expected dispatch queue label to match expected value")
        
        XCTAssertEqual(queue.qos, .userInitiated,
                       "Expected dispatch queue qos to match expected value")
    }
    
    func test_initForType_withNoBundleId_createsNewDispatchQueueWithCorrectValues() throws {
        DispatchQueue.getBundleIdHandler = { nil }
        
        let queue = DispatchQueue(for: Self.self, name: "MockQueue", qos: .userInitiated)
        
        XCTAssertEqual(queue.label, "<unknown-bundle>.TwitchKit.DispatchQueueExtensionTests.MockQueue",
                       "Expected dispatch queue label to match expected value")
        
        XCTAssertEqual(queue.qos, .userInitiated,
                       "Expected dispatch queue qos to match expected value")
        
        DispatchQueue.getBundleIdHandler = { Bundle.main.bundleIdentifier }
    }
}
