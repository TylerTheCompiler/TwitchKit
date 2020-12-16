//
//  ChatMessageClearChat.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// A message that is sent when all chat messages are purged in a channel, or when chat messages from a
    /// specific user are purged (typically after a timeout or ban).
    public struct ClearChat {
        
        /// Duration of the timeout, in seconds. If omitted, the ban is permanent.
        public let banDuration: Int?
        
        /// The user that had their message cleared.
        public let user: String?
        
        /// The channel this message was sent to.
        public let channel: String
        
        internal init(dictionary: [String: String]) throws {
            guard let channel = dictionary["channel"] else {
                throw ChatMessageError.unhandledMessage
            }
            
            banDuration = dictionary["ban-duration"].flatMap { Int($0) }
            user = dictionary["user"]
            self.channel = channel
        }
    }
}
