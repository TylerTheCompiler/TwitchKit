//
//  UserFollow.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Represents the following of one Twitch user to another.
public struct UserFollow: Decodable {
    
    /// ID of the user following the `toId` user.
    public let fromId: String
    
    /// Display name corresponding to `fromId`.
    public let fromName: String
    
    /// ID of the user being followed by the `fromId` user.
    public let toId: String
    
    /// Display name corresponding to `toId`.
    public let toName: String
    
    /// Date and time when the `fromId` user followed the `toId` user.
    @InternetDate
    public private(set) var followedAt: Date
}
