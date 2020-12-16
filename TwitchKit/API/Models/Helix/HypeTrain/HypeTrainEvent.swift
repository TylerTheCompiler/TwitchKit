//
//  HypeTrainEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Information about an ongoing or most-recent Hype Train in a channel.
public struct HypeTrainEvent: Decodable {
    
    /// The type of Hype Train event. Currently only `.hypeTrainProgression`.
    public enum EventType: String, Decodable {
        
        /// The event when the Hype Train has progressed to a higher level.
        case hypeTrainProgression = "hypetrain.progression"
    }
    
    /// A contribution to a Hype Train made by a user.
    public struct Contribution: Decodable {
        
        /// The type of Hype Train contribution, either bits or subs.
        public enum ContributionType: String, Decodable {
            case bits = "BITS"
            case subs = "SUBS"
        }
        
        /// Total amount contributed. If type is BITS, total represents amounts of bits used.
        /// If type is SUBS, total is 500, 1000, or 2500 to represent tier 1, 2, or 3 subscriptions
        /// respectively
        public let total: Int
        
        /// Identifies the contribution method, either BITS or SUBS
        public let type: ContributionType
        
        /// ID of the contributing user
        public let user: String
    }
    
    /// Additional Hype Train event data.
    public struct EventData: Decodable {
        
        /// Channel ID of which Hype Train events the clients are interested in
        public let broadcasterId: String
        
        /// RFC3339 formatted timestamp of when another Hype Train can be started again
        @InternetDateWithFractionalSeconds
        public private(set) var cooldownEndTime: Date
        
        /// RFC3339 formatted timestamp of the expiration time of this Hype Train
        @InternetDateWithFractionalSeconds
        public private(set) var expiresAt: Date
        
        /// The goal value of the level of the Hype Train
        public let goal: Int
        
        /// The distinct ID of this Hype Train
        public let id: String
        
        /// An object that represents the most recent contribution
        public let lastContribution: Contribution
    }
    
    /// The distinct ID of the event
    public let id: String
    
    /// Displays hypetrain.{event_name}, currently only hypetrain.progression
    public let eventType: EventType
    
    /// RFC3339 formatted timestamp of event
    @InternetDate
    public private(set) var eventTimestamp: Date // "2020-04-24T20:07:24Z"
    
    /// Returns the version of the endpoint
    public let version: String
    
    /// Additional Hype Train event data.
    public let eventData: EventData
    
    /// The highest level (in the scale of 1-5) reached of the Hype Train
    public let level: Int
    
    /// RFC3339 formatted timestamp of when this Hype Train started
    @InternetDateWithFractionalSeconds
    public private(set) var startedAt: Date // 2020-04-24T20:05:47.30473127Z
    
    /// An array of top contribution objects, one object for each type. For example, one object would
    /// represent top contributor of BITS, by aggregate, and one would represent top contributor of
    /// SUBS by count.
    public let topContributions: [Contribution]
    
    /// The total score so far towards completing the level goal
    public let total: Int
}
