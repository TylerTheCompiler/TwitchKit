//
//  ChatMessageHostMode.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// A message sent when a channel starts host mode.
    public struct HostMode {
        
        /// The channel being hosted.
        public let channel: String
        
        /// The channel doing the hosting of `channel`.
        public let hostingChannel: String
        
        /// The number of viewers from the `hostingChannel` that are watching `channel` via the host.
        public let numberOfViewers: Int?
    }
}
