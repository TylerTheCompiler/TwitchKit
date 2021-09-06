//
//  EventSubChannelSubscribe.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// A channel subscription event.
    ///
    /// Contains the user ID and user name of the subscriber, the broadcaster user ID and broadcaster user name,
    /// and whether the subscription is a gift.
    public struct ChannelSubscribe: Decodable {
        
        /// The tier of the subscription.
        public enum Tier: String, Decodable {
            
            /// A tier 1 subscription.
            case tier1 = "1000"
            
            /// A tier 2 subscription.
            case tier2 = "2000"
            
            /// A tier 3 subscription.
            case tier3 = "3000"
        }
        
        /// The user ID for the user who subscribed to the specified channel.
        public let userId: String
        
        /// The user login for the user who subscribed to the specified channel.
        public let userLogin: String
        
        /// The user name for the user who subscribed to the specified channel.
        public let userName: String
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster login.
        public let broadcasterUserLogin: String
        
        /// The requested broadcaster name.
        public let broadcasterUserName: String
        
        /// The tier of the subscription. Valid values are 1000, 2000, and 3000.
        public let tier: Tier
        
        /// Whether the subscription is a gift.
        public let isGift: Bool
    }
}
