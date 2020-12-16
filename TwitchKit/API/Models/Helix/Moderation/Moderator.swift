//
//  Moderator.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A user that is a moderator of a channel.
public struct Moderator: Decodable {
    
    /// User ID of a user who is a moderator.
    private let userId: String
    
    /// Display name of a user who is a moderator.
    private let userName: String
}
