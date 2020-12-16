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
    public func open(_ completion: ((_ success: Bool) -> Void)? = nil) {
        #if os(macOS)
        let didOpen = Self.workspace.open(url)
        completion?(didOpen)
        #else
        Self.application.open(url, options: [:], completionHandler: completion)
        #endif
    }
    
    /// Whether the native Twitch app is installed.
    public static var isTwitchAppInstalled: Bool {
        #if os(macOS)
        return Self.workspace.urlForApplication(toOpen: login.url) != nil
        #else
        return Self.application.canOpenURL(login.url)
        #endif
    }
    
    #if os(macOS)
    internal static var workspace: WorkspaceProtocol = NSWorkspace.shared
    #else
    internal static var application: ApplicationProtocol = UIApplication.shared
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
