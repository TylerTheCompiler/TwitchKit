//
//  ClientIdAuthSession.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/9/20.
//

/// An auth session used when only a client ID is needed and no access token is needed.
///
/// You do not make instances of this auth session yourself.
public struct ClientIdAuthSession: AuthSession {
    
    /// The client ID of your application.
    public let clientId: String
}
