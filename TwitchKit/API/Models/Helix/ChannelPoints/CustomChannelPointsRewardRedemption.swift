//
//  CustomChannelPointsRewardRedemption.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension CustomChannelPointsReward {
    
    /// An object that represents a redemption of a custom channel points reward by a user.
    public struct Redemption: Decodable {
        
        /// The status of a custom channel points reward redemption.
        public enum Status: String, Codable {
            
            /// The custom reward redemption has not been fulfilled yet.
            case unfulfilled = "UNFULFILLED"
            
            /// The custom reward redemption has been fulfilled.
            case fulfilled = "FULFILLED"
            
            /// The custom reward redemption has been canceled/rejected.
            case canceled = "CANCELED"
        }
        
        /// Additional information about the custom reward that the redemption belongs to.
        public struct Reward: Decodable {
            
            /// ID of the reward.
            public let id: String
            
            /// The title of the reward.
            public let title: String
            
            /// The prompt for the viewer when they are redeeming the reward.
            public let prompt: String
            
            /// The cost of the reward in channel points.
            public let cost: Int
        }
        
        /// The ID of the broadcaster that the reward belongs to.
        public let broadcasterId: String
        
        /// The display name of the broadcaster that the reward belongs to.
        public let broadcasterName: String
        
        /// The ID of the redemption.
        public let id: String
        
        /// The ID of the user that redeemed the reward
        public let userId: String
        
        /// The display name of the user that redeemed the reward.
        public let userName: String
        
        /// Basic information about the Custom Reward that was redeemed at the time it was redeemed.
        public let reward: Reward
        
        /// The user input provided. Empty string if not provided.
        public let userInput: String
        
        /// One of UNFULFILLED, FULFILLED or CANCELED
        public let status: Status
        
        /// RFC3339 timestamp of when the reward was redeemed.
        @InternetDate
        public private(set) var redeemedAt: Date
    }
}
