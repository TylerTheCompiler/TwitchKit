//
//  TwitchAppDeepLink.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/21/20.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A deep link into the official native Twitch app.
public enum TwitchAppDeepLink {
    
    /// A deep link to a channel with the given name.
    case channel(name: String)
    
    /// A deep link to a directory for a game with the given name.
    case game(name: String)
    
    /// A deep link to a VOD with the given video ID.
    case vod(videoId: String)
    
    /// A deep link to the currently-logged-in user's following directory.
    case following
    
    /// A deep link to the login screen.
    case login
    
    /// A deep link to a category tag directory.
    case categoryTag(id: String)
    
    /// A deep link to a live stream tag directory.
    case liveStreamTag(id: String)
    
    /// The URL that the deep link goes to.
    public var url: URL {
        var components = URLComponents()
        components.scheme = "twitch"
        switch self {
        case .channel(let channelName):
            components.host = "stream"
            components.path = "/" + channelName
            
        case .game(let gameName):
            components.host = "game"
            components.path = "/" + gameName
            
        case .vod(let videoId):
            components.host = "video"
            components.path = "/" + videoId
            
        case .following:
            components.host = "following"
            
        case .login:
            components.host = "login"
            
        case .categoryTag(let tagId):
            components.host = "directory"
            components.path = "/tags/" + tagId
            
        case .liveStreamTag(let tagId):
            components.host = "directory"
            components.path = "/all/tags/" + tagId
        }
        
        // swiftlint:disable:next force_unwrapping
        return components.url!
    }
    
    /// Attempts to open the native Twitch app and navigate to the deep link.
    ///
    /// - Parameter completion: A closure to be called when the deep link finishes opening or fails to open.
    ///                         The `Bool` parameter indicates whether the deep link was successfully opened
    ///                         or not.
    @MainActor
    public func open(_ completion: ((_ success: Bool) -> Void)? = nil) {
        #if os(macOS)
        let didOpen = (Self.injectedWorkspace ?? NSWorkspace.shared).open(url)
        completion?(didOpen)
        #else
        (Self.injectedApplication ?? UIApplication.shared).open(
            url,
            options: [:],
            completionHandler: completion
        )
        #endif
    }
    
    #if os(macOS)
    /// Whether the native Twitch app is installed or not.
    public static var isTwitchAppInstalled: Bool {
        (Self.injectedWorkspace ?? NSWorkspace.shared).urlForApplication(toOpen: login.url) != nil
    }
    #else
    
    /// Whether the native Twitch app is installed or not.
    ///
    /// - Important: In order for this to ever return `true`, you must declare the "twitch" URL scheme
    ///              in your app's Info.plist file. If you do not, then this always returns `false`.
    @MainActor
    public static var isTwitchAppInstalled: Bool {
        (Self.injectedApplication ?? UIApplication.shared).canOpenURL(login.url)
    }
    #endif
    
    #if os(macOS)
    internal static var injectedWorkspace: WorkspaceProtocol?
    #else
    internal static var injectedApplication: ApplicationProtocol?
    #endif
}

#if os(macOS)
internal protocol WorkspaceProtocol: AnyObject {
    func urlForApplication(toOpen url: URL) -> URL?
    func open(_ url: URL) -> Bool
}

extension NSWorkspace: WorkspaceProtocol {}
#else
internal protocol ApplicationProtocol: AnyObject {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL,
              options: [UIApplication.OpenExternalURLOptionsKey: Any],
              completionHandler: ((Bool) -> Void)?)
}

extension UIApplication: ApplicationProtocol {}
#endif
