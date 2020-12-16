//
//  EventSubChannelCheer.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct ChannelCheer: Decodable {
        
        /// Whether the user cheered anonymously or not.
        public let isAnonymous: Bool
        
        /// The user ID for the user who cheered on the specified channel.
        /// This is empty if `isAnonymous` is true.
        public let userId: String
        
        /// The user name for the user who cheered on the specified channel.
        /// This is empty if `isAnonymous` is true.
        public let userName: String
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster name.
        public let broadcasterUserName: String
        
        /// The message sent with the cheer.
        public let message: String
        
        /// The number of bits cheered.
        public let bits: Int
    }
}
