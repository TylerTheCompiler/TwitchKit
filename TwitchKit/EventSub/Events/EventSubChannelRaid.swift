//
//  EventSubChannelRaid.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 9/6/21.
//

extension EventSub.Event {
    
    /// A channel raid event.
    ///
    /// Contains the from and to broadcaster information along with the number of viewers in the raid.
    /// Will only notify for raids that appear in chat.
    public struct ChannelRaid: Decodable {
        
        /// The broadcaster ID that created the raid.
        public let fromBroadcasterUserId: String
        
        /// The broadcaster login that created the raid.
        public let fromBroadcasterUserLogin: String
        
        /// The broadcaster display name that created the raid.
        public let fromBroadcasterUserName: String
        
        /// The broadcaster ID that received the raid.
        public let toBroadcasterUserId: String
        
        /// The broadcaster login that received the raid.
        public let toBroadcasterUserLogin: String
        
        /// The broadcaster display name that received the raid.
        public let toBroadcasterUserName: String
        
        /// The number of viewers in the raid.
        public let viewers: Int
    }
}
