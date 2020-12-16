//
//  EventSubChannelPointsCustomRewardRedemption.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct ChannelPointsCustomRewardRedemption: Decodable {
        
        /// <#Description#>
        public enum Status: String, Decodable {
            
            /// <#Description#>
            case unfulfilled
            
            /// <#Description#>
            case fulfilled
            
            /// <#Description#>
            case canceled
            
            /// <#Description#>
            case unknown
        }
        
        /// <#Description#>
        public struct Reward: Decodable {
            
            /// The reward identifier.
            public let id: String
            
            /// The reward name.
            public let title: String
            
            /// The reward cost.
            public let cost: Int
            
            /// The reward description.
            public let prompt: String
        }
        
        /// The redemption identifier.
        public let id: String
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster name.
        public let broadcasterUserName: String
        
        /// User ID of the user that redeemed the reward.
        public let userId: String
        
        /// Display name of the user that redeemed the reward.
        public let userName: String
        
        /// The user input provided. Empty string if not provided.
        public let userInput: String
        
        /// Defaults to unfulfilled. Possible values are unknown, unfulfilled, fulfilled, and canceled.
        public let status: Status
        
        /// Basic information about the reward that was redeemed, at the time it was redeemed.
        public let reward: Reward
        
        /// RFC3339 timestamp of when the reward was redeemed.
        @InternetDateWithOptionalFractionalSeconds
        public private(set) var redeemedAt: Date
    }
}
