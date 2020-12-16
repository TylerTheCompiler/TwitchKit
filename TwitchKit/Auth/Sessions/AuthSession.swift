//
//  AuthSession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/9/20.
//

/// A type that can be used for authorizing a user or an app through Twitch.
public protocol AuthSession {
    
    /// The client ID of the Twitch application being authorized for.
    var clientId: String { get }
}

/// An internal protocol used by the framework to obtain the auth session's URL session configuration.
internal protocol InternalAuthSession: AuthSession {
    
    /// The configuration used by the auth session's internal URL session.
    var urlSessionConfiguration: URLSessionConfiguration { get }
}
