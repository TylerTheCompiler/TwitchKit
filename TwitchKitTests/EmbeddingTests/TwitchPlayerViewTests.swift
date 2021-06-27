//
//  TwitchPlayerViewTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/12/20.
//

import XCTest
@testable import TwitchKit

import WebKit

class MockWebView: WKWebView {
    override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        return nil
    }
}

//class MockSecurityOrigin: WKSecurityOrigin {
//    var testHost: String
//
//    init(testHost: String) {
//        self.testHost = testHost
//    }
//
//    override var host: String {
//        testHost
//    }
//}

extension WKSecurityOrigin {
    private static var isHostSwizzled = false
    static func swizzleHostIfNeeded() {
        if !isHostSwizzled {
            isHostSwizzled = true
            let originalSelector = #selector(getter:host)
            let swizzledSelector = #selector(twitchKitTests_host)
            let originalHostMethod = class_getInstanceMethod(self, originalSelector)!
            let swizzledHostMethod = class_getInstanceMethod(self, swizzledSelector)!
            method_exchangeImplementations(originalHostMethod, swizzledHostMethod)
        }
    }
    
    @objc func twitchKitTests_host() -> String {
        testHost ?? twitchKitTests_host()
    }
    
    private static var testHostKey = 0
    
    var testHost: String? {
        get { objc_getAssociatedObject(self, &Self.testHostKey) as? String }
        set { objc_setAssociatedObject(self, &Self.testHostKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

class MockWebViewFrameInfo: WKFrameInfo {
    var testHost: String?
    
    init(testHost: String) {
        self.testHost = testHost
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let frame = super.copy(with: zone) as! MockWebViewFrameInfo
        frame.testHost = testHost
        return frame
    }
    
    override var securityOrigin: WKSecurityOrigin {
        let securityOrigin = super.securityOrigin
        securityOrigin.testHost = testHost
        WKSecurityOrigin.swizzleHostIfNeeded()
        return securityOrigin
    }
}

class TwitchPlayerViewTests: XCTestCase {
    var mockFrameInfo: MockWebViewFrameInfo!
    
    override class func setUp() {
        TwitchWebView.webViewType = MockWebView.self
    }
    
    func test_playerView_withNilContent_hasNilHTMLString() {
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: nil))
        
        XCTAssertNil(playerView.htmlStringForWebView, "Expected nil HTML string")
    }
    
    func test_playerView_channel_hasCorrectHTML() {
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: .channel(name: "SomeChannel")))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <div style="margin:0;" id="twitch-embed"></div>
                <script src="https://embed.twitch.tv/embed/v1.js"></script>
                <script type="text/javascript">
                    new Twitch.Embed("twitch-embed", {
                        channel: "SomeChannel", width: "100%", height: "100%", allowfullscreen: true, autoplay: true, layout: "video", muted: false, theme: "dark", time: "0h0m0", parent: ["twitch.tv"]
                    });
                </script>
            </body>
        </html>
        """
        
        XCTAssertEqual(playerView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_playerView_video_hasCorrectHTML() {
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: .video(id: "SomeVideoId")))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <div style="margin:0;" id="twitch-embed"></div>
                <script src="https://embed.twitch.tv/embed/v1.js"></script>
                <script type="text/javascript">
                    new Twitch.Embed("twitch-embed", {
                        video: "SomeVideoId", width: "100%", height: "100%", allowfullscreen: true, autoplay: true, layout: "video", muted: false, theme: "dark", time: "0h0m0", parent: ["twitch.tv"]
                    });
                </script>
            </body>
        </html>
        """
        
        XCTAssertEqual(playerView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_playerView_collection_hasCorrectHTML() {
        let playerView = TwitchPlayerView(
            frame: .init(x: 0, y: 0, width: 375, height: 211),
            settings: .init(content: .collection(id: "SomeCollectionId", initialVideoId: "SomeVideoId"))
        )
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <div style="margin:0;" id="twitch-embed"></div>
                <script src="https://embed.twitch.tv/embed/v1.js"></script>
                <script type="text/javascript">
                    new Twitch.Embed("twitch-embed", {
                        collection: "SomeCollectionId", video: "SomeVideoId", width: "100%", height: "100%", allowfullscreen: true, autoplay: true, layout: "video", muted: false, theme: "dark", time: "0h0m0", parent: ["twitch.tv"]
                    });
                </script>
            </body>
        </html>
        """
        
        XCTAssertEqual(playerView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_playerView_customParents_hasCorrectHTML() {
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: .channel(name: "SomeChannel"),
                                                          parents: ["SomeParent1", "SomeParent2"]))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <div style="margin:0;" id="twitch-embed"></div>
                <script src="https://embed.twitch.tv/embed/v1.js"></script>
                <script type="text/javascript">
                    new Twitch.Embed("twitch-embed", {
                        channel: "SomeChannel", width: "100%", height: "100%", allowfullscreen: true, autoplay: true, layout: "video", muted: false, theme: "dark", time: "0h0m0", parent: ["SomeParent1", "SomeParent2"]
                    });
                </script>
            </body>
        </html>
        """
        
        XCTAssertEqual(playerView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_playerView_updatingSettings_updatesHTML() {
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: .channel(name: "SomeChannel")))
        
        var expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <div style="margin:0;" id="twitch-embed"></div>
                <script src="https://embed.twitch.tv/embed/v1.js"></script>
                <script type="text/javascript">
                    new Twitch.Embed("twitch-embed", {
                        channel: "SomeChannel", width: "100%", height: "100%", allowfullscreen: true, autoplay: true, layout: "video", muted: false, theme: "dark", time: "0h0m0", parent: ["twitch.tv"]
                    });
                </script>
            </body>
        </html>
        """
        
        XCTAssertEqual(playerView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
        
        playerView.settings = .init(content: .video(id: "SomeVideoId"),
                                    size: (.absolute(1920), .absolute(1080)))
        
        expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <div style="margin:0;" id="twitch-embed"></div>
                <script src="https://embed.twitch.tv/embed/v1.js"></script>
                <script type="text/javascript">
                    new Twitch.Embed("twitch-embed", {
                        video: "SomeVideoId", width: 1920, height: 1080, allowfullscreen: true, autoplay: true, layout: "video", muted: false, theme: "dark", time: "0h0m0", parent: ["twitch.tv"]
                    });
                </script>
            </body>
        </html>
        """
        
        XCTAssertEqual(playerView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_playerView_initWithCoder_works() {
        let bundle = Bundle(for: TwitchPlayerViewTests.self)
        
        #if os(macOS)
        let nib = NSNib(nibNamed: "TwitchPlayerView-macOS", bundle: bundle)
        var topLevelObjectsNSArray: NSArray?
        guard nib?.instantiate(withOwner: nil, topLevelObjects: &topLevelObjectsNSArray) ?? false else {
            XCTFail("Expected nib instantiation to succeed")
            return
        }
        
        let topLevelObjects = topLevelObjectsNSArray as [AnyObject]?
        #else
        let nib = UINib(nibName: "TwitchPlayerView-iOS", bundle: bundle)
        let topLevelObjects: [Any]? = nib.instantiate(withOwner: nil)
        #endif
        
        
        let playerView = topLevelObjects?.compactMap { $0 as? TwitchPlayerView }.first
        XCTAssertNotNil(playerView, "Expected player view to be instantiated")
    }
    
    class MockUIDelegate: TwitchWebViewUIDelegate {
        var okPressed = false
        
        init(okPressed: Bool) {
            self.okPressed = okPressed
        }
        
        func twitchWebView(_ twitchWebView: TwitchWebView,
                           didReceive chatConfirmationDialog: TwitchWebView.ChatConfirmationDialog) {
            chatConfirmationDialog.completionHandler(okPressed)
        }
    }
    
    func test_javascriptConfirmationPrompt_works() {
        let taskToFinish = expectation(description: "Expected task to finish")
        let expectedOKPressedValue = true
        
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: .channel(name: "SomeChannel")))
        let mockUIDelegate = MockUIDelegate(okPressed: expectedOKPressedValue)
        mockFrameInfo = MockWebViewFrameInfo(testHost: "embed.twitch.tv")
        
        playerView.uiDelegate = mockUIDelegate
        
        let message = """
        You are attempting to send "Some message" in SomeChannel's chat via an embedded version of Twitch Chat. \
        Are you sure you want to do this? This setting will persist until you refresh the page.
        """
        
        playerView.webView(playerView.webView!,
                           runJavaScriptConfirmPanelWithMessage: message,
                           initiatedByFrame: mockFrameInfo) { okPressed in
            XCTAssertEqual(okPressed, expectedOKPressedValue, "Expected okPressed value to be expected value")
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_givenWrongHost_javascriptConfirmationPrompt_returnsFalseOKPressedValue() {
        let taskToFinish = expectation(description: "Expected task to finish")
        let expectedOKPressedValue = false
        
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: .channel(name: "SomeChannel")))
        let mockUIDelegate = MockUIDelegate(okPressed: expectedOKPressedValue)
        mockFrameInfo = MockWebViewFrameInfo(testHost: "some.random.host.com")
        
        playerView.uiDelegate = mockUIDelegate
        
        let message = """
        You are attempting to send "Some message" in SomeChannel's chat via an embedded version of Twitch Chat. \
        Are you sure you want to do this? This setting will persist until you refresh the page.
        """
        
        playerView.webView(playerView.webView!,
                           runJavaScriptConfirmPanelWithMessage: message,
                           initiatedByFrame: mockFrameInfo) { okPressed in
            XCTAssertEqual(okPressed, expectedOKPressedValue, "Expected okPressed value to be expected value")
            taskToFinish.fulfill()
        }
        
        wait(for: [taskToFinish], timeout: 1.0)
    }
    
    func test_createChildWebView_addsChildWebViewToChildWebViewsArray() {
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: .channel(name: "SomeChannel")))
        let newWebView = playerView.webView(playerView.webView!,
                                            createWebViewWith: playerView.webView!.configuration,
                                            for: .init(),
                                            windowFeatures: .init())
        
        XCTAssertFalse(playerView.closeButton.isHidden, "Expected close button to be unhidden")
        XCTAssertEqual(playerView.closeButton, playerView.subviews.last, "Expected close button to be topmost view")
        XCTAssertEqual(newWebView, playerView.childWebViews.last, "Expected new webview to be the last child webview")
        XCTAssertEqual(newWebView, playerView.subviews.dropLast().last, "Expected new webview to be second topmost view")
    }
    
    func test_webViewDidClose_closesChildWebview() {
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: .channel(name: "SomeChannel")))
        guard let newWebView = playerView.webView(playerView.webView!,
                                                  createWebViewWith: playerView.webView!.configuration,
                                                  for: .init(),
                                                  windowFeatures: .init()) else {
            XCTFail("Expected new web view to be created")
            return
        }
        
        playerView.webViewDidClose(newWebView)
        
        XCTAssertTrue(playerView.closeButton.isHidden, "Expected close button to be hidden")
        XCTAssertEqual(playerView.closeButton, playerView.subviews.last, "Expected close button to be topmost view")
        XCTAssertFalse(playerView.childWebViews.contains(newWebView), "Expected new webview to not be in childWebViews array")
        XCTAssertFalse(playerView.subviews.contains(newWebView), "Expected new webview to not be a subview")
    }
    
    func test_closeButton_closesChildWebview() {
        let playerView = TwitchPlayerView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(content: .channel(name: "SomeChannel")))
        guard let newWebView = playerView.webView(playerView.webView!,
                                                  createWebViewWith: playerView.webView!.configuration,
                                                  for: .init(),
                                                  windowFeatures: .init()) else {
            XCTFail("Expected new web view to be created")
            return
        }
        
        #if os(macOS)
        playerView.closeButton.performClick(nil)
        #else
        playerView.closeTopChildWebView(playerView.closeButton)
        #endif
        
        XCTAssertTrue(playerView.closeButton.isHidden, "Expected close button to be hidden")
        XCTAssertEqual(playerView.closeButton, playerView.subviews.last, "Expected close button to be topmost view")
        XCTAssertFalse(playerView.childWebViews.contains(newWebView), "Expected new webview to not be in childWebViews array")
        XCTAssertFalse(playerView.subviews.contains(newWebView), "Expected new webview to not be a subview")
    }
}
