//
//  Team.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// A Twitch team.
public struct Team: Decodable {
    
    /// A user belonging to a Twitch Team.
    public struct Member: Decodable {
        
        /// User ID of the Team member.
        public let userId: String
        
        /// Display name of the Team member.
        public let userName: String
        
        /// Login of the Team member.
        public let userLogin: String
    }
    
    /// Team ID.
    public let id: String
    
    /// Team name.
    public let teamName: String
    
    /// Team display name.
    public let teamDisplayName: String
    
    /// Team description.
    public let info: String
    
    /// User ID of the broadcaster.
    public let broadcasterId: String?
    
    /// Login of the broadcaster.
    public let broadcasterLogin: String?
    
    /// Display name of the broadcaster.
    public let broadcasterName: String?
    
    /// Users in the specified Team.
    @EmptyIfNull
    public private(set) var users: [Member]
    
    /// URL for the Team banner.
    @SafeURL
    public private(set) var banner: URL?
    
    /// URL for the Team background image.
    @SafeURL
    public private(set) var backgroundImageUrl: URL?
    
    /// Image URL for the Team logo.
    @SafeURL
    public private(set) var thumbnailUrl: URL?
    
    /// Date and time the Team was created.
    @InternetDateWithFractionalSeconds
    public private(set) var createdAt: Date
    
    /// Date and time the Team was last updated.
    @InternetDateWithFractionalSeconds
    public private(set) var updatedAt: Date
}
