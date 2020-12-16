//
//  LegacyGetChatBadgesByChannelRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of badges that can be used in chat for a specified channel.
public struct LegacyGetChatBadgesByChannelRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// If the channel has a subsciber badge, this is the badge for tier 1 subscibers. Otherwise, this is nil.
        public let subscriber: LegacyChatBadge?
        
        /// The badge used for admin users.
        public let admin: LegacyChatBadge
        
        /// The badge used for the broadcaster.
        public let broadcaster: LegacyChatBadge
        
        /// The badge used for global moderators.
        public let globalMod: LegacyChatBadge
        
        /// The badge used for channel moderators.
        public let mod: LegacyChatBadge
        
        /// The badge used for Twitch staff.
        public let staff: LegacyChatBadge
        
        /// The badge used for Twitch Turbo users.
        public let turbo: LegacyChatBadge
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get Chat Badges By Channel legacy request.
    ///
    /// - Parameter channelId: The channel from which to fetch chat badges.
    public init(channelId: String) {
        path = "/chat/\(channelId)/badges"
    }
}
