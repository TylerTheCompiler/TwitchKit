//
//  EventSubChannelBan.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct ChannelBan: Decodable {
        
        /// The user ID for the user who was banned on the specified channel.
        public let userId: String
        
        /// The user name for the user who was banned on the specified channel.
        public let userName: String
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster name.
        public let broadcasterUserName: String
    }
}
