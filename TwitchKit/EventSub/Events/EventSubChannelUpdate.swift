//
//  EventSubChannelUpdate.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct ChannelUpdate: Decodable {
        
        /// The broadcaster’s user ID.
        public let broadcasterUserId: String
        
        /// The broadcaster’s user name.
        public let broadcasterUserName: String
        
        /// The channel’s stream title.
        public let title: String
        
        /// The channel’s broadcast language.
        public let language: String
        
        /// The channel’s category ID.
        public let categoryId: String
        
        /// The category name.
        public let categoryName: String
        
        /// A boolean identifying whether the channel is flagged as mature. Valid values are true and false.
        public let isMature: Bool
    }
}
