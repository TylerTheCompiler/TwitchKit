//
//  EventSubChannelSubscriptionEnd.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 9/6/21.
//

extension EventSub.Event {
    
    /// A channel subscription end event.
    ///
    /// Contains the user ID, user login, and user display name of the user whose subscription has expired, as
    /// well as the broadcaster user ID, broadcaster login, and broadcaster display name.
    public struct ChannelSubscriptionEnd: Decodable {
        
        /// The tier of the subscription.
        public enum Tier: String, Decodable {
            
            /// A tier 1 subscription.
            case tier1 = "1000"
            
            /// A tier 2 subscription.
            case tier2 = "2000"
            
            /// A tier 3 subscription.
            case tier3 = "3000"
        }
        
        /// The user ID for the user whose subscription ended.
        public let userId: String
        
        /// The user login for the user whose subscription ended.
        public let userLogin: String
        
        /// The user display name for the user whose subscription ended.
        public let userName: String
        
        /// The broadcaster user ID.
        public let broadcasterUserId: String
        
        /// The broadcaster login.
        public let broadcasterUserLogin: String
        
        /// The broadcaster display name.
        public let broadcasterUserName: String
        
        /// The tier of the subscription that ended. Valid values are 1000, 2000, and 3000.
        public let tier: Tier
        
        /// Whether the subscription was a gift.
        public let isGift: Bool
    }
}
