//
//  ChatMessageUnhostMode.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// A message sent when a channel stops host mode.
    public struct UnhostMode {
        
        /// The channel that stopped host mode.
        public let hostingChannel: String
        
        /// The number of viewers that are no longer watching the hosted channel.
        public let numberOfViewers: Int?
    }
}
