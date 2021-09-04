//
//  EventSubStreamOffline.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct StreamOffline: Decodable {
        
        /// The broadcaster's user id.
        public let broadcasterUserId: String
        
        /// The broadcaster's user name.
        public let broadcasterUserName: String
    }
}
