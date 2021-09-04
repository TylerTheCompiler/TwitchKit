//
//  EventSubUserUpdate.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct UserUpdate: Decodable {
        
        /// The user's user id.
        public let userId: String
        
        /// The user's user name.
        public let userName: String
        
        /// The user's email. Only included if you have the user:read:emailscope for the user.
        public let email: String?
        
        /// The user's description.
        public let description: String
    }
}
