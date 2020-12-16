//
//  TwitchClipViewTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/12/20.
//

import XCTest
@testable import TwitchKit

class TwitchClipViewTests: XCTestCase {
    override class func setUp() {
        TwitchWebView.webViewType = MockWebView.self
    }
    
    func test_clipView_withNilClipSlug_hasNilHTMLString() {
        let clipView = TwitchClipView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(clipSlug: nil))
        
        XCTAssertNil(clipView.htmlStringForWebView, "Expected nil HTML string")
    }
    
    func test_clipView_channel_hasCorrectHTML() {
        let clipView = TwitchClipView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(clipSlug: "SomeClipSlug"))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    src="https://clips.twitch.tv/embed?clip=SomeClipSlug&autoplay=true&muted=false&parent=twitch.tv&darkpopout"
                    width="100%"
                    height="100%"
                    preload="metadata"
                    frameborder="0"
                    scrolling="no"
                    allowfullscreen="false">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(clipView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_clipView_channel_andScrollingIsTrue_hasCorrectHTML() {
        let clipView = TwitchClipView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(clipSlug: "SomeClipSlug", isScrollingEnabled: true))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    src="https://clips.twitch.tv/embed?clip=SomeClipSlug&autoplay=true&muted=false&parent=twitch.tv&darkpopout"
                    width="100%"
                    height="100%"
                    preload="metadata"
                    frameborder="0"
                    scrolling="yes"
                    allowfullscreen="false">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(clipView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_clipView_customParents_hasCorrectHTML() {
        let clipView = TwitchClipView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(clipSlug: "SomeClipSlug", parents: ["SomeParent1", "SomeParent2"]))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    src="https://clips.twitch.tv/embed?clip=SomeClipSlug&autoplay=true&muted=false&parent=SomeParent1&parent=SomeParent2&darkpopout"
                    width="100%"
                    height="100%"
                    preload="metadata"
                    frameborder="0"
                    scrolling="no"
                    allowfullscreen="false">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(clipView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_clipView_updatingSettings_updatesHTML() {
        let clipView = TwitchClipView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                          settings: .init(clipSlug: "SomeClipSlug"))
        
        var expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    src="https://clips.twitch.tv/embed?clip=SomeClipSlug&autoplay=true&muted=false&parent=twitch.tv&darkpopout"
                    width="100%"
                    height="100%"
                    preload="metadata"
                    frameborder="0"
                    scrolling="no"
                    allowfullscreen="false">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(clipView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
        
        clipView.settings.clipSlug = "SomeOtherClipSlug"
        
        expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    src="https://clips.twitch.tv/embed?clip=SomeOtherClipSlug&autoplay=true&muted=false&parent=twitch.tv&darkpopout"
                    width="100%"
                    height="100%"
                    preload="metadata"
                    frameborder="0"
                    scrolling="no"
                    allowfullscreen="false">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(clipView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_clipView_lightMode_hasCorrectHTML() {
        let clipView = TwitchClipView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(clipSlug: "SomeClipSlug", theme: .light))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    src="https://clips.twitch.tv/embed?clip=SomeClipSlug&autoplay=true&muted=false&parent=twitch.tv"
                    width="100%"
                    height="100%"
                    preload="metadata"
                    frameborder="0"
                    scrolling="no"
                    allowfullscreen="false">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(clipView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_clipView_initWithCoder_works() {
        let bundle = Bundle(for: TwitchClipViewTests.self)
        
        #if os(macOS)
        let nib = NSNib(nibNamed: "TwitchClipView-macOS", bundle: bundle)
        var topLevelObjectsNSArray: NSArray?
        guard nib?.instantiate(withOwner: nil, topLevelObjects: &topLevelObjectsNSArray) ?? false else {
            XCTFail("Expected nib instantiation to succeed")
            return
        }
        
        let topLevelObjects = topLevelObjectsNSArray as [AnyObject]?
        #else
        let nib = UINib(nibName: "TwitchClipView-iOS", bundle: bundle)
        let topLevelObjects: [Any]? = nib.instantiate(withOwner: nil)
        #endif
        
        
        let clipView = topLevelObjects?.compactMap { $0 as? TwitchClipView }.first
        XCTAssertNotNil(clipView, "Expected clip view to be instantiated")
    }
}
