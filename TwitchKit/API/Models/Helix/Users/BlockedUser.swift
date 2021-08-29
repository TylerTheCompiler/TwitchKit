//
//  BlockedUser.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/28/21.
//

/// A user that has been blocked by another user.
public struct BlockedUser: Decodable {
    
    /// User ID of the blocked user.
    public let userId: String
    
    /// Login of the blocked user.
    public let userLogin: String
    
    /// Display name of the blocked user.
    public let displayName: String
}
