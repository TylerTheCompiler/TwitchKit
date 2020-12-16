//
//  ChatMessageClearMessage.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// A message sent when a single message is removed from a channel.
    /// This is triggered by the `/delete <target-msg-id>` command on IRC.
    public struct ClearMessage {
        
        /// Name of the user who sent the removed message.
        public let login: String
        
        /// UUID of the removed message.
        public let targetMessageId: String
        
        /// The channel this message was sent to.
        public let channel: String
        
        /// The message that was removed.
        public let message: String
        
        internal init(dictionary: [String: String]) throws {
            guard let channel = dictionary["channel"],
                  let message = dictionary["message"],
                  let login = dictionary["login"],
                  let targetMessageId = dictionary["targetMessageId"] else {
                throw ChatMessageError.unhandledMessage
            }
            
            self.login = login
            self.targetMessageId = targetMessageId
            self.channel = channel
            self.message = message
        }
    }
}
