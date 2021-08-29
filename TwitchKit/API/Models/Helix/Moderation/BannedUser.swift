//
//  BannedUser.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Represents a user that has been banned from a channel.
public struct BannedUser: Decodable {
    
    /// User ID of a user who has been banned.
    public let userId: String
    
    /// Login of the banned user.
    public let userLogin: String
    
    /// Display name of a user who has been banned.
    public let userName: String
    
    /// RFC3339 formatted timestamp for timeouts; empty string for bans.
    @OptionalInternetDate
    public private(set) var expiresAt: Date?
}
