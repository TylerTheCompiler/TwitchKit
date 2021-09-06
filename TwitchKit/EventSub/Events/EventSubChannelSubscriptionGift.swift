//
//  EventSubChannelSubscriptionGift.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 9/5/21.
//

extension EventSub.Event {
    
    /// A channel subscription gift event.
    ///
    /// Contains information about the user who gave the gift subscriptions, and the number and tier of
    /// subscriptions included in the gift.
    public struct ChannelSubscriptionGift: Decodable {
        
        /// The tier of the subscription.
        public enum Tier: String, Decodable {
            
            /// A tier 1 subscription.
            case tier1 = "1000"
            
            /// A tier 2 subscription.
            case tier2 = "2000"
            
            /// A tier 3 subscription.
            case tier3 = "3000"
        }
        
        /// The user ID of the user who sent the subscription gift.
        ///
        /// Set to nil if it was an anonymous subscription gift.
        public let userId: String?
        
        /// The user login of the user who sent the gift.
        ///
        /// Set to nil if it was an anonymous subscription gift.
        public let userLogin: String?
        
        /// The user display name of the user who sent the gift.
        ///
        /// Set to nil if it was an anonymous subscription gift.
        public let userName: String?
        
        /// The broadcaster user ID.
        public let broadcasterUserId: String
        
        /// The broadcaster login.
        public let broadcasterUserLogin: String
        
        /// The broadcaster display name.
        public let broadcasterUserName: String
        
        /// The number of subscriptions in the subscription gift.
        public let total: Int
        
        /// The tier of subscriptions in the subscription gift.
        public let tier: Tier
        
        /// The number of subscriptions gifted by this user in the channel.
        ///
        /// This value is nil for anonymous gifts or if the gifter has opted out of sharing this information.
        public let cumulativeTotal: Int?
        
        /// Whether the subscription gift was anonymous.
        public let isAnonymous: Bool
    }
}
