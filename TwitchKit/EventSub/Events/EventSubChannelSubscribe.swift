//
//  EventSubChannelSubscribe.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct ChannelSubscribe: Decodable {
        
        /// <#Description#>
        public enum Tier: String, Decodable {
            
            /// <#Description#>
            case tier1 = "1000"
            
            /// <#Description#>
            case tier2 = "2000"
            
            /// <#Description#>
            case tier3 = "3000"
        }
        
        /// The user ID for the user who subscribed to the specified channel.
        public let userId: String
        
        /// The user name for the user who subscribed to the specified channel.
        public let userName: String
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster name.
        public let broadcasterUserName: String
        
        /// The tier of the subscription. Valid values are 1000, 2000, and 3000.
        public let tier: Tier
        
        /// Whether the subscription is a gift.
        public let isGift: Bool
    }
}
