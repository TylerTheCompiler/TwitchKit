//
//  LegacyUpdateChannelRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Updates specified properties of a specified channel.
public struct LegacyUpdateChannelRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyChannel
    
    /// The properties of a channel to update.
    public struct LegacyChannelPropertiesToUpdate: Equatable, Encodable {
        
        /// Description of the broadcaster’s status, displayed as a title on the channel page.
        public let status: String?
        
        /// Name of game.
        public let game: String?
        
        /// Channel delay, in seconds. This inserts a delay in the live feed.
        /// Requires the channel owner’s OAuth token.
        public let delay: String?
        
        /// If true, the channel’s feed is turned on. Requires the channel owner’s OAuth token.
        public let channelFeedEnabled: Bool?
    }
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The properties of a channel to update.
        public let channel: LegacyChannelPropertiesToUpdate
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .put
    public let path: String
    public let body: RequestBody?
    
    /// Creates a new Update Channel legacy request.
    ///
    /// - Parameters:
    ///   - channelId: The channel ID of the channel to update.
    ///   - status: Description of the broadcaster’s status, displayed as a title on the channel page. Default: nil.
    ///   - game: Name of game. Default: nil.
    ///   - delay: Channel delay, in seconds. This inserts a delay in the live feed. Requires the channel owner’s
    ///            OAuth token. Default: nil.
    ///   - channelFeedEnabled: If true, the channel’s feed is turned on. Requires the channel owner’s OAuth token.
    ///                         Default: nil (effectively false).
    public init(channelId: String,
                status: String? = nil,
                game: String? = nil,
                delay: Int? = nil,
                channelFeedEnabled: Bool? = nil) {
        path = "/channels/\(channelId)"
        body = .init(channel: .init(status: status,
                                    game: game,
                                    delay: delay?.description,
                                    channelFeedEnabled: channelFeedEnabled))
    }
}
