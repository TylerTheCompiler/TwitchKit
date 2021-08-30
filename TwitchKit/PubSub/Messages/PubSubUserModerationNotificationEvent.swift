//
//  PubSubUserModerationNotificationEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub.Message {
    
    /// A user's message held by AutoMod has been approved or denied.
    public struct UserModerationNotificationEvent: Decodable {
        
        /// Additional `UserModerationNotificationEvent` info.
        public struct Data: Decodable {
            
            /// Identifier of the message
            public let messageId: String
                
            /// Current status of the message
            public let status: ChatMessageStatus
        }
        
        /// The type of message.
        public let type: String
        
        /// Additional event info.
        public let data: Data
    }
}
