//
//  ModeratorEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// An event that occurs when a user is added or removed as a moderator of a channel.
public struct ModeratorEvent: Decodable {
    
    /// The type of moderator event.
    public enum EventType: String, Decodable {
        
        /// The user was granted moderator privileges in a channel.
        case add = "moderation.moderator.add"
        
        /// The user had their moderator privileges revoked from a channel.
        case remove = "moderation.moderator.remove"
    }
    
    /// Additional event data relating to the moderator event.
    public struct EventData: Decodable {
        
        /// ID of the broadcaster adding or removing moderators.
        public let broadcasterId: String
        
        /// Name of the broadcaster adding or removing moderators.
        public let broadcasterName: String
        
        /// ID of the user being added or removed as moderator.
        public let userId: String
        
        /// Name of the user being added or removed as moderator.
        public let userName: String
    }
    
    /// User ID of the moderator.
    public let id: String
    
    /// Whether the event was the adding or removing of a moderator.
    public let eventType: EventType
    
    /// RFC3339 formatted timestamp for the event.
    @InternetDate
    public private(set) var eventTimestamp: Date
    
    /// The version of the endpoint.
    public let version: String
    
    /// Additional event data relating to the moderator event.
    public let eventData: EventData
}
