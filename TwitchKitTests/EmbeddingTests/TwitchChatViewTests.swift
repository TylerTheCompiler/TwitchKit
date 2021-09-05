//
//  TwitchChatViewTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/12/20.
//

import XCTest
@testable import TwitchKit

class TwitchChatViewTests: XCTestCase {
    override class func setUp() {
        TwitchWebView.webViewType = MockWebView.self
    }
    
    func test_chatView_withNilChannel_hasNilHTMLString() {
        let chatView = TwitchChatView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(channel: nil))
        
        XCTAssertNil(chatView.htmlStringForWebView, "Expected nil HTML string")
    }
    
    func test_chatView_hasCorrectHTML() {
        let chatView = TwitchChatView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(channel: "SomeChannel"))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    frameborder="0"
                    scrolling="no"
                    src="https://www.twitch.tv/embed/SomeChannel/chat?parent=twitch.tv&darkpopout"
                    width="100%"
                    height="100%">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(chatView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_chatView_andScrollingIsTrue_hasCorrectHTML() {
        let chatView = TwitchChatView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(channel: "SomeChannel", isScrollingEnabled: true))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    frameborder="0"
                    scrolling="yes"
                    src="https://www.twitch.tv/embed/SomeChannel/chat?parent=twitch.tv&darkpopout"
                    width="100%"
                    height="100%">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(chatView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_chatView_customParents_hasCorrectHTML() {
        let chatView = TwitchChatView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(channel: "SomeChannel", parents: ["SomeParent1", "SomeParent2"]))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    frameborder="0"
                    scrolling="no"
                    src="https://www.twitch.tv/embed/SomeChannel/chat?parent=SomeParent1&parent=SomeParent2&darkpopout"
                    width="100%"
                    height="100%">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(chatView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_chatView_lightMode_hasCorrectHTML() {
        let chatView = TwitchChatView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(channel: "SomeChannel", theme: .light))
        
        let expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    frameborder="0"
                    scrolling="no"
                    src="https://www.twitch.tv/embed/SomeChannel/chat?parent=twitch.tv"
                    width="100%"
                    height="100%">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(chatView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_chatView_updatingSettings_updatesHTML() {
        let chatView = TwitchChatView(frame: .init(x: 0, y: 0, width: 375, height: 211),
                                      settings: .init(channel: "SomeChannel"))
        
        var expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    frameborder="0"
                    scrolling="no"
                    src="https://www.twitch.tv/embed/SomeChannel/chat?parent=twitch.tv&darkpopout"
                    width="100%"
                    height="100%">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(chatView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
        
        chatView.settings.channel = "SomeOtherChannel"
        
        expectedHTML = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0,             maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    frameborder="0"
                    scrolling="no"
                    src="https://www.twitch.tv/embed/SomeOtherChannel/chat?parent=twitch.tv&darkpopout"
                    width="100%"
                    height="100%">
                </iframe>
            </body>
        </html>
        """
        
        XCTAssertEqual(chatView.htmlStringForWebView, expectedHTML, "Incorrect HTML")
    }
    
    func test_chatView_initWithCoder_works() {
        let bundle = Bundle(for: TwitchChatViewTests.self)
        
        #if os(macOS)
        let nib = NSNib(nibNamed: "TwitchChatView-macOS", bundle: bundle)
        var topLevelObjectsNSArray: NSArray?
        guard nib?.instantiate(withOwner: nil, topLevelObjects: &topLevelObjectsNSArray) ?? false else {
            XCTFail("Expected nib instantiation to succeed")
            return
        }
        
        let topLevelObjects = topLevelObjectsNSArray as [AnyObject]?
        #else
        let nib = UINib(nibName: "TwitchChatView-iOS", bundle: bundle)
        let topLevelObjects: [Any]? = nib.instantiate(withOwner: nil)
        #endif
        
        
        let chatView = topLevelObjects?.compactMap { $0 as? TwitchChatView }.first
        XCTAssertNotNil(chatView, "Expected chat view to be instantiated")
    }
    
    // MARK: - Chat Confirmation Dialog
    
    #if os(macOS)
    @MainActor
    func test_chatConfirmationDialog_showsInWindow_andOKIsPressed() {
        class MockAlertThatPressesOK: NSAlert {
            override func beginSheetModal(
                for sheetWindow: NSWindow,
                completionHandler handler: ((NSApplication.ModalResponse) -> Void)? = nil
            ) {
                handler?(.alertFirstButtonReturn)
            }
        }
        
        let dialogToBeDismissed = expectation(description: "Expected dialog to be dismissed")
        let completionToBeCalled = expectation(description: "Epxected completion to be called")
        
        let dialog = TwitchWebView.ChatConfirmationDialog(title: "SomeTitle", message: "SomeMessage") { okPressed in
            XCTAssertTrue(okPressed)
            dialogToBeDismissed.fulfill()
        }
        
        dialog.alertType = MockAlertThatPressesOK.self
        
        dialog.show(in: NSWindow()) {
            completionToBeCalled.fulfill()
        }
        
        wait(for: [dialogToBeDismissed, completionToBeCalled], timeout: 1.0, enforceOrder: true)
    }
    
    @MainActor
    func test_chatConfirmationDialog_showsInWindow_andCancelIsPressed() {
        class MockAlertThatPressesCancel: NSAlert {
            override func beginSheetModal(
                for sheetWindow: NSWindow,
                completionHandler handler: ((NSApplication.ModalResponse) -> Void)? = nil
            ) {
                handler?(.alertSecondButtonReturn)
            }
        }
        
        let dialogToBeDismissed = expectation(description: "Expected dialog to be dismissed")
        let completionToBeCalled = expectation(description: "Epxected completion to be called")
        
        let dialog = TwitchWebView.ChatConfirmationDialog(title: "SomeTitle", message: "SomeMessage") { okPressed in
            XCTAssertFalse(okPressed)
            dialogToBeDismissed.fulfill()
        }
        
        dialog.alertType = MockAlertThatPressesCancel.self
        
        dialog.show(in: NSWindow()) {
            completionToBeCalled.fulfill()
        }
        
        wait(for: [dialogToBeDismissed, completionToBeCalled], timeout: 1.0, enforceOrder: true)
    }
    #else
    
    class MockViewController: UIViewController {
        var indexOfButtonToPress = 0
        
        override func present(_ viewControllerToPresent: UIViewController,
                              animated flag: Bool,
                              completion: (() -> Void)? = nil) {
            guard let alertController = viewControllerToPresent as? UIAlertController,
                  let action = alertController.actions[indexOfButtonToPress] as? MockAlertAction else {
                return
            }
            
            completion?()
            
            action.mockHandler?(action)
        }
    }
    
    class MockAlertAction: UIAlertAction {
        typealias Handler = ((UIAlertAction) -> Void)
        
        var mockHandler: Handler?
        var mockTitle: String?
        var mockStyle: UIAlertAction.Style
        
        override class func makeAction(withTitle title: String?,
                                       style: UIAlertAction.Style,
                                       handler: Handler?) -> UIAlertAction {
            MockAlertAction(title: title, style: style, handler: handler)
        }
        
        convenience init(title: String?, style: UIAlertAction.Style, handler: Handler?) {
            self.init()
            mockTitle = title
            mockStyle = style
            mockHandler = handler
        }
        
        override init() {
            mockStyle = .default
            super.init()
        }
    }
    
    func test_chatConfirmationDialog_showsFromViewController_andOKIsPressed() {
        let dialogToBeDismissed = expectation(description: "Expected dialog to be dismissed")
        let completionToBeCalled = expectation(description: "Epxected completion to be called")
        
        let dialog = TwitchWebView.ChatConfirmationDialog(title: "SomeTitle", message: "SomeMessage") { okPressed in
            XCTAssertTrue(okPressed)
            dialogToBeDismissed.fulfill()
        }
        
        dialog.alertActionType = MockAlertAction.self
        
        let mockViewController = MockViewController()
        mockViewController.indexOfButtonToPress = 0
        
        dialog.show(from: mockViewController) {
            completionToBeCalled.fulfill()
        }
        
        wait(for: [completionToBeCalled, dialogToBeDismissed], timeout: 1.0, enforceOrder: true)
    }
    
    func test_chatConfirmationDialog_showsFromViewController_andCancelIsPressed() {
        let dialogToBeDismissed = expectation(description: "Expected dialog to be dismissed")
        let completionToBeCalled = expectation(description: "Epxected completion to be called")
        
        let dialog = TwitchWebView.ChatConfirmationDialog(title: "SomeTitle", message: "SomeMessage") { okPressed in
            XCTAssertFalse(okPressed)
            dialogToBeDismissed.fulfill()
        }
        
        dialog.alertActionType = MockAlertAction.self
        
        let mockViewController = MockViewController()
        mockViewController.indexOfButtonToPress = 1
        
        dialog.show(from: mockViewController) {
            completionToBeCalled.fulfill()
        }
        
        wait(for: [completionToBeCalled, dialogToBeDismissed], timeout: 1.0, enforceOrder: true)
    }
    
    func test_UIAlertAction_helperMethod() {
        let title = "SomeTitle"
        let style = UIAlertAction.Style.destructive
        let action = UIAlertAction.makeAction(withTitle: title, style: style) { _ in }
        
        XCTAssertEqual(action.title, title)
        XCTAssertEqual(action.style, style)
    }
    #endif
}
