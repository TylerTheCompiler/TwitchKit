//
//  PubSubSubscriptionEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub.Message {
    
    /// A PubSub event received when anyone subscribes (first month), resubscribes (subsequent months), or gifts a
    /// subscription to a channel. Subgift subscription messages contain recipient information.
    public struct SubscriptionEvent: Decodable {
        
        /// Å message a user sends along with a subscription event.
        public struct SubMessage: Decodable {
            
            /// A range of an emote in the message the user sent.
            public struct EmoteRange: Decodable {
                
                /// The starting index of an emote.
                public let start: Int
                
                /// The ending index of an emote.
                public let end: Int
                
                /// The ID of the emote found in the range [start, end] of the message the user sent.
                public let id: Int
            }
            
            /// The raw message string that the user sent along with the subscription event.
            public let message: String
            
            /// The ranges of emotes found in `message`.
            public let emotes: [EmoteRange]?
        }
        
        /// Event type associated with the subscription product.
        public enum Context: String, Decodable {
            case sub
            case resub
            case subGift = "subgift"
            case anonSubGift = "anonsubgift"
            case resubGift = "resubgift"
            case anonresubgift = "anonResubGift"
        }
        
        /// Subscription plan ID.
        public enum SubPlan: String, Decodable {
            case prime = "Prime"
            case tier1 = "1000"
            case tier2 = "2000"
            case tier3 = "3000"
        }
        
        /// Login name of the person who subscribed or sent a gift subscription.
        public let userName: String?
        
        /// Display name of the person who subscribed or sent a gift subscription.
        public let displayName: String?
        
        /// User ID of the person who subscribed or sent a gift subscription.
        public let userId: String?
        
        /// Name of the channel that has been subscribed or subgifted.
        public let channelName: String
        
        /// ID of the channel that has been subscribed or subgifted.
        public let channelId: String
        
        /// Subscription plan ID.
        public let subPlan: SubPlan
        
        /// Channel Specific Subscription Plan Name
        public let subPlanName: String
        
        /// Cumulative number of tenure months of the subscription.
        public let cumulativeMonths: Int
        
        /// Denotes the user’s most recent (and contiguous) subscription tenure streak in the channel.
        public let streakMonths: Int
        
        /// Event type associated with the subscription product.
        public let context: Context
        
        /// If this sub message was caused by a gift subscription.
        public let isGift: Bool
        
        /// The message that the user sent along with the subscription event.
        public let subMessage: SubMessage
        
        /// User ID of the subscription gift recipient.
        public let recipientId: String?
        
        /// Login name of the subscription gift recipient.
        public let recipientUserName: String?
        
        /// Display name of the person who received the subscription gift.
        public let recipientDisplayName: String?
        
        /// Number of months gifted as part of a single, multi-month gift OR number of months purchased as part of a
        /// multi-month subscription.
        public let multiMonthDuration: Int?
        
        /// Time when the subscription or gift was completed.
        @InternetDate
        public private(set) var time: Date
    }
}
