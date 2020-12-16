//
//  ClientAuthSessionPresentationContextProviding.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

#if os(macOS)
import AppKit

/// An `NSWindow` on macOS and a `UIWindow` on iOS/tvOS.
public typealias PresentationAnchor = NSWindow

/// An `NSView` on macOS and a `UIView` on iOS/tvOS.
public typealias PlatformIndependentView = NSView

/// An `NSViewController` on macOS and a `UIViewController` on iOS/tvOS.
public typealias PlatformIndependentViewController = NSViewController
#else
import UIKit

/// A `UIWindow` on iOS/tvOS and an `NSWindow` on macOS.
public typealias PresentationAnchor = UIWindow

/// A `UIView` on iOS/tvOS and an `NSView` on macOS.
public typealias PlatformIndependentView = UIView

/// A `UIViewController` on iOS/tvOS and an `NSViewController` on macOS.
public typealias PlatformIndependentViewController = UIViewController
#endif

/// A type that can provide a presentation anchor from which to display authorization UI to the user.
public protocol ClientAuthSessionPresentationContextProviding: AnyObject {
    
    /// Tells the delegate from which window it should present content to the user.
    ///
    /// - Parameter session: The session asking for the presentation anchor.
    /// - Returns: The window from which content should be presented to the user.
    func presentationAnchor(for session: ClientAuthSession) -> PresentationAnchor
}

#if os(macOS)
extension NSView: ClientAuthSessionPresentationContextProviding {
    
    /// Tells the session to ask the view's `window` for the presentation anchor.
    ///
    /// - Important: If the view is not in a window, this causes a crash!
    ///
    /// - Parameter session: The session asking for the presentation anchor.
    /// - Returns: The presentation anchor returned by the view's `window`.
    public func presentationAnchor(for session: ClientAuthSession) -> PresentationAnchor {
        window!.presentationAnchor(for: session) // swiftlint:disable:this force_unwrapping
    }
}

extension NSWindow: ClientAuthSessionPresentationContextProviding {
    
    /// Tells the session to use the window as the presentation anchor.
    ///
    /// - Parameter session: The session asking for the presentation anchor.
    /// - Returns: The window.
    public func presentationAnchor(for session: ClientAuthSession) -> PresentationAnchor {
        self
    }
}
#else
extension UIView: ClientAuthSessionPresentationContextProviding {
    
    /// Tells the session to use the view's `window` as the presentation anchor, or to use the view itself if
    /// it is a `UIWindow`.
    ///
    /// - Important: If the view is not a `UIWindow` itself and is not in a window, this causes a crash!
    ///
    /// - Parameter session: The session asking for the presentation anchor.
    /// - Returns: If the view is a `UIWindow`, the view. Otherwise, the view's `window`.
    public func presentationAnchor(for session: ClientAuthSession) -> PresentationAnchor {
        if let selfAsAnchor = self as? PresentationAnchor {
            return selfAsAnchor
        }
        
        return window! // swiftlint:disable:this force_unwrapping
    }
}
#endif

extension PlatformIndependentViewController: ClientAuthSessionPresentationContextProviding {
    
    /// Tells the session to use the presentation anchor of the view controller's `view`.
    ///
    /// - Parameter session: The session asking for the presentation anchor.
    /// - Returns: The presentation anchor returned by the view controller's `view`.
    public func presentationAnchor(for session: ClientAuthSession) -> PresentationAnchor {
        view.presentationAnchor(for: session)
    }
}
