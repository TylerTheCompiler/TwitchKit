//
//  BitLeader.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Information about a user and their Bits leaderboard score/rank in a channel.
public struct BitLeader: Decodable {
    
    /// Leaderboard rank of the user.
    public let rank: Int
    
    /// Leaderboard score (number of Bits) of the user.
    public let score: Int
    
    /// ID of the user (viewer) in the leaderboard entry.
    public let userId: String
    
    /// User login name.
    public let userLogin: String
    
    /// Display name corresponding to `userId`.
    public let userName: String
}
