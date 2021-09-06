//
//  EventSubChannelSubscriptionMessage.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 9/5/21.
//

extension EventSub.Event {
    
    /// A channel subscription message event.
    ///
    /// Contains information about the user who resubscribed and their resubscription chat message.
    public struct ChannelSubscriptionMessage: Decodable {
        
        /// The tier of the subscription.
        public enum Tier: String, Decodable {
            
            /// A tier 1 subscription.
            case tier1 = "1000"
            
            /// A tier 2 subscription.
            case tier2 = "2000"
            
            /// A tier 3 subscription.
            case tier3 = "3000"
        }
        
        /// An object that contains the resubscription message and emote information needed to
        /// recreate the resubscription message.
        public struct Message: Decodable {
            
            /// An object that includes the emote ID and start and end positions for where the emote appears in the text.
            public struct Emote: Decodable {
                
                /// The index of where the Emote starts in the text.
                public let begin: Int
                
                /// The index of where the Emote ends in the text.
                public let end: Int
                
                /// The emote ID.
                public let id: String
            }
            
            /// The text of the resubscription chat message.
            public let text: String
            
            /// An array of emote IDs and their start and end positions for where each emote appears in the text.
            public let emotes: [Emote]
        }
        
        /// The user ID of the user who sent a resubscription chat message.
        public let userId: String
        
        /// The user login of the user who sent a resubscription chat message.
        public let userLogin: String
        
        /// The user display name of the user who a resubscription chat message.
        public let userName: String
        
        /// The broadcaster user ID.
        public let broadcasterUserId: String
        
        /// The broadcaster login.
        public let broadcasterUserLogin: String
        
        /// The broadcaster display name.
        public let broadcasterUserName: String
        
        /// The tier of the user's subscription.
        public let tier: Tier
        
        /// An object that contains the resubscription message and emote information needed to recreate the message.
        public let message: Message
        
        /// The total number of months the user has been subscribed to the channel.
        public let cumulativeTotal: Int
        
        /// The number of consecutive months the user's current subscription has been active.
        ///
        /// This value is nil if the user has opted out of sharing this information.
        public let streakMonths: Int?
        
        /// The month duration of the subscription.
        public let durationMonths: Int
    }
}
