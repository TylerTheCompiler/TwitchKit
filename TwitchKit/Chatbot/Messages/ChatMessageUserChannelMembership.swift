//
//  ChatMessageUserChannelMembership.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// A message sent when a user joins or leaves a channel.
    public struct UserChannelMembership {
        
        /// The channel that the user joined or left.
        public let channel: String
        
        /// The nickname of the user who joined or left the channel.
        public let nick: String?
        
        /// The username of the user who joined or left the channel.
        public let user: String?
        
        /// The host of the user who joined or left the channel.
        public let host: String?
        
        internal init(dictionary: [String: String]) throws {
            guard let channel = dictionary["channel"] else {
                throw ChatMessageError.unhandledMessage
            }
            
            self.channel = channel
            nick = dictionary["nick"]
            user = dictionary["user"]
            host = dictionary["host"]
        }
    }
}
