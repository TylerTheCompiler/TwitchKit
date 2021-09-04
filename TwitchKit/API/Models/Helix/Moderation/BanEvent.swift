//
//  BanEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A ban or unban event in a channel.
public struct BanEvent: Decodable {
    
    /// The type of ban event.
    public enum EventType: String, Decodable {
        
        /// The event was a banning of a user.
        case ban = "moderation.user.ban"
        
        /// The event was an unbanning of a user.
        case unban = "moderation.user.unban"
    }
    
    /// Additional event data relating to the ban event.
    public struct EventData: Decodable {
        
        /// The ID of the channel in which the ban event took place.
        public let broadcasterId: String
        
        /// Broadcaster's user login name.
        public let broadcasterLogin: String
        
        /// The username of the channel in which the ban event took place.
        public let broadcasterName: String
        
        /// User ID of the user who has been banned or unbanned.
        public let userId: String
        
        /// Login of the banned user.
        public let userLogin: String
        
        /// Display name of the user who has been banned or unbanned.
        public let userName: String
        
        /// The date at which the ban expires. Bans are currently permanent (until unbanned), so this is always nil.
        @OptionalInternetDateWithFractionalSeconds
        public private(set) var expiresAt: Date?
    }
    
    /// Event ID.
    public let id: String
    
    /// Whether the event was a ban or an unban.
    public let eventType: EventType
    
    /// RFC3339 formatted timestamp for the ban event.
    @InternetDate
    public private(set) var eventTimestamp: Date
    
    /// The version of the endpoint.
    public let version: String
    
    /// Additional event data relating to the ban event.
    public let eventData: EventData
}
