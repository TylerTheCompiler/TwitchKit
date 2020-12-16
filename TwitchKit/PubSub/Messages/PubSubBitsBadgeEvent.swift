//
//  PubSubBitsBadgeEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub.Message {
    
    /// A PubSub event received when a user earns a new Bits badge in a particular channel, and chooses to share the
    /// notification with chat.
    public struct BitsBadgeEvent: Decodable {
        
        /// ID of user who earned the new Bits badge.
        public let userId: String
        
        /// Login of user who earned the new Bits badge.
        public let userName: String
        
        /// ID of channel where user earned the new Bits badge.
        public let channelId: String
        
        /// Login of channel where user earned the new Bits badge.
        public let channelName: String
        
        /// Value of Bits badge tier that was earned (1000, 10000, etc.).
        public let badgeTier: Int
        
        /// Custom message included with share, if any.
        public let chatMessage: String?
        
        /// Time when the new Bits badge was earned.
        @InternetDateWithFractionalSeconds
        public private(set) var time: Date
    }
}
