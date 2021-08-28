//
//  Prediction.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

/// A Twitch chat prediction.
public struct Prediction: Decodable {
    
    /// Information about an outcome of a Prediction.
    public struct Outcome: Decodable {
        
        /// Information about a user who participated in a Prediction.
        public struct Predictor: Decodable {
            
            /// ID of the user.
            public let id: String
            
            /// Display name of the user.
            public let name: String
            
            /// Login of the user.
            public let login: String
            
            /// Number of Channel Points used by the user.
            public let channelPointsUsed: Int
            
            /// Number of Channel Points won by the user.
            public let channelPointsWon: Int
        }
        
        public enum Color: String, Decodable {
            case blue = "BLUE"
            case pink = "PINK"
        }
        
        /// ID for the outcome.
        public let id: String
        
        /// Text displayed for outcome.
        public let title: String
        
        /// Number of unique users that chose the outcome.
        public let users: Int
        
        /// Number of Channel Points used for the outcome.
        public let channelPoints: Int
        
        /// Array of users who were the top predictors.
        @EmptyIfNull
        public private(set) var topPredictors: [Predictor]
        
        /// Color for the outcome.
        public let color: Color
    }
    
    /// Status of a Prediction.
    public enum Status: String, Decodable {
        
        /// A winning outcome has been chosen and the Channel Points have been distributed to the users
        /// who guessed the correct outcome.
        case resolved = "RESOLVED"
        
        /// The Prediction is active and viewers can make predictions.
        case active = "ACTIVE"
        
        /// The Prediction has been canceled and the Channel Points have been refunded to participants.
        case canceled = "CANCELED"
        
        /// The Prediction has been locked and viewers can no longer make predictions.
        case locked = "LOCKED"
    }
    
    /// ID of the Prediction.
    public let id: String
    
    /// ID of the broadcaster.
    public let broadcasterId: String
    
    /// Name of the broadcaster.
    public let broadcasterName: String
    
    /// Login of the broadcaster.
    public let broadcasterLogin: String
    
    /// Title for the Prediction.
    public let title: String
    
    /// ID of the winning outcome. If the status is `.active`, this is set to nil.
    public let winningOutcomeId: String?
    
    /// Array of possible outcomes for the Prediction.
    public let outcomes: [Outcome]
    
    /// Total duration for the Prediction (in seconds).
    public let predictionWindow: Int
    
    /// Status of the Prediction.
    public let status: Status
    
    /// The Prediction's start time.
    @InternetDateWithFractionalSeconds
    public private(set) var createdAt: Date
    
    /// When the Prediction ended, or nil if the status is `.active`.
    @OptionalInternetDateWithFractionalSeconds
    public private(set) var endedAt: Date?
    
    /// When the Prediction was locked, or nil if the status is not `.locked`.
    @OptionalInternetDateWithFractionalSeconds
    public private(set) var lockedAt: Date?
}
