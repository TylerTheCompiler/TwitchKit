//
//  EventSubChannelModeratorRemove.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 9/6/21.
//

extension EventSub.Event {
    
    /// A moderator remove event.
    ///
    /// Contains user information of the old moderator as well as broadcaster information of the
    /// channel the event occurred on.
    public struct ChannelModeratorRemove: Decodable {
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster login.
        public let broadcasterUserLogin: String
        
        /// The requested broadcaster display name.
        public let broadcasterUserName: String
        
        /// The user ID of the removed moderator.
        public let userId: String
        
        /// The user login of the removed moderator.
        public let userLogin: String
        
        /// The display name of the removed moderator.
        public let userName: String
    }
}
