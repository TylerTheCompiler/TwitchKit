//
//  Poll.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

/// A Twitch chat poll.
public struct Poll: Decodable {
    
    /// A choice presented in a Twitch chat poll.
    public struct Choice: Decodable {
        
        /// ID for the choice.
        public let id: String
        
        /// Text displayed for the choice.
        public let title: String
        
        /// Total number of votes received for the choice across all methods of voting.
        public let votes: Int
        
        /// Number of votes received via Channel Points.
        public let channelPointsVotes: Int
        
        /// Number of votes received via Bits.
        public let bitsVotes: Int
    }
    
    /// Poll status.
    public enum Status: String, Decodable {
        
        /// Poll is currently in progress.
        case active = "ACTIVE"
        
        /// Poll has reached its ended_at time.
        case completed = "COMPLETED"
        
        /// Poll has been manually terminated before its ended_at time.
        case terminated = "TERMINATED"
        
        /// Poll is no longer visible on the channel.
        case archived = "ARCHIVED"
        
        /// Poll is no longer visible to any user on Twitch.
        case moderated = "MODERATED"
        
        /// Something went wrong determining the state.
        case invalid = "INVALID"
        
        public init(rawValue: String) {
            switch rawValue {
            case Self.active.rawValue: self = .active
            case Self.completed.rawValue: self = .completed
            case Self.terminated.rawValue: self = .terminated
            case Self.archived.rawValue: self = .archived
            case Self.moderated.rawValue: self = .moderated
            case Self.invalid.rawValue: self = .invalid
            default: self = .invalid
            }
        }
    }
    
    /// ID of the poll.
    public let id: String
    
    /// ID of the broadcaster.
    public let broadcasterId: String
    
    /// Name of the broadcaster.
    public let broadcasterName: String
    
    /// Login of the broadcaster.
    public let broadcasterLogin: String
    
    /// Question displayed for the poll.
    public let title: String
    
    /// Array of the poll choices.
    public let choices: [Choice]
    
    /// Indicates if Bits can be used for voting.
    public let bitsVotingEnabled: Bool
    
    /// Number of Bits required to vote once with Bits.
    public let bitsPerVote: Int
    
    /// Indicates if Channel Points can be used for voting.
    public let channelPointsVotingEnabled: Bool
    
    /// Number of Channel Points required to vote once with Channel Points.
    public let channelPointsPerVote: Int
    
    /// Poll status.
    public let status: Status
    
    /// Total duration for the poll (in seconds).
    public let duration: Int
    
    /// The poll's start time.
    @InternetDateWithFractionalSeconds
    public private(set) var startedAt: Date
    
    /// The poll's end time. Nil if the poll is active.
    @OptionalInternetDateWithFractionalSeconds
    public private(set) var endedAt: Date?
}
