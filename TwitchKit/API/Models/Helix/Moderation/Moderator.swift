//
//  Moderator.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A user that is a moderator of a channel.
public struct Moderator: Decodable {
    
    /// User ID of a user who is a moderator.
    public let userId: String
    
    /// Login of a moderator in the channel.
    public let userLogin: String
    
    /// Display name of a user who is a moderator.
    public let userName: String
}
