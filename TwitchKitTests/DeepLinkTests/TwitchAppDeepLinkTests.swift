//
//  TwitchAppDeepLinkTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/11/20.
//

import XCTest
@testable import TwitchKit

class TwitchAppDeepLinkTests: XCTestCase {
    #if os(macOS)
    class MockWorkspace: WorkspaceProtocol {
        var wasURLForApplicationCalled = false
        var wasOpenURLCalled = false
        
        func urlForApplication(toOpen url: URL) -> URL? {
            wasURLForApplicationCalled = true
            return URL(fileURLWithPath: "/path/to/app")
        }
        
        func open(_ url: URL) -> Bool {
            wasOpenURLCalled = true
            return true
        }
    }
    
    var workspace: MockWorkspace!
    
    override func setUp() {
        workspace = MockWorkspace()
        TwitchAppDeepLink.injectedWorkspace = workspace
    }
    
    override func tearDown() {
        workspace = nil
        TwitchAppDeepLink.injectedWorkspace = NSWorkspace.shared
    }
    #else
    class MockApplication: ApplicationProtocol {
        var wasCanOpenURLCalled = false
        var wasOpenURLCalled = false
        
        func canOpenURL(_ url: URL) -> Bool {
            wasCanOpenURLCalled = true
            return true
        }
        
        func open(_ url: URL,
                  options: [UIApplication.OpenExternalURLOptionsKey: Any],
                  completionHandler: ((Bool) -> Void)?) {
            wasOpenURLCalled = true
            completionHandler?(true)
        }
    }
    
    var application: MockApplication!
    
    override func setUp() {
        application = MockApplication()
        TwitchAppDeepLink.injectedApplication = application
    }
    
    override func tearDown() {
        application = nil
        TwitchAppDeepLink.injectedApplication = UIApplication.shared
    }
    #endif
    
    func test_url_hasCorrectValue() throws {
        XCTAssertEqual(TwitchAppDeepLink.channel(name: "TestChannel").url,
                       URL(string: "twitch://stream/TestChannel")!)
        XCTAssertEqual(TwitchAppDeepLink.game(name: "TestGame").url,
                       URL(string: "twitch://game/TestGame")!)
        XCTAssertEqual(TwitchAppDeepLink.vod(videoId: "TestVideoId").url,
                       URL(string: "twitch://video/TestVideoId")!)
        XCTAssertEqual(TwitchAppDeepLink.following.url,
                       URL(string: "twitch://following")!)
        XCTAssertEqual(TwitchAppDeepLink.login.url,
                       URL(string: "twitch://login")!)
        XCTAssertEqual(TwitchAppDeepLink.categoryTag(id: "TestCategoryTag").url,
                       URL(string: "twitch://directory/tags/TestCategoryTag")!)
        XCTAssertEqual(TwitchAppDeepLink.liveStreamTag(id: "TestLiveStreamTag").url,
                       URL(string: "twitch://directory/all/tags/TestLiveStreamTag")!)
    }
    
    @MainActor
    func test_open_works() throws {
        let openToBeCalled = expectation(description: "Expected open to be called")
        #if os(macOS)
        XCTAssertFalse(workspace.wasOpenURLCalled, "Expected openURL to not be called yet")
        #else
        XCTAssertFalse(application.wasOpenURLCalled, "Expected openURL to not be called yet")
        #endif
        
        TwitchAppDeepLink.login.open { _ in
            #if os(macOS)
            XCTAssertTrue(self.workspace.wasOpenURLCalled, "Expected openURL to be called")
            #else
            XCTAssertTrue(self.application.wasOpenURLCalled, "Expected openURL to be called")
            #endif
            openToBeCalled.fulfill()
        }
        
        wait(for: [openToBeCalled], timeout: 1.0)
    }
    
    @MainActor
    func test_isTwitchAppInstalled_works() throws {
        #if os(macOS)
        XCTAssertFalse(workspace.wasURLForApplicationCalled, "Expected urlForApp to not be called yet")
        #else
        XCTAssertFalse(application.wasCanOpenURLCalled, "Expected canOpenURL to not be called yet")
        #endif
        _ = TwitchAppDeepLink.isTwitchAppInstalled
        #if os(macOS)
        XCTAssertTrue(workspace.wasURLForApplicationCalled, "Expected urlForApp to be called")
        #else
        XCTAssertTrue(application.wasCanOpenURLCalled, "Expected canOpenURL to be called")
        #endif
    }
}
