//
//  GetChannelChatBadgesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/26/21.
//

/// Gets a list of custom chat badges that can be used in chat for the specified channel.
///
/// This includes [subscriber badges][1] and [Bit badges][2].
///
/// [1]: https://help.twitch.tv/s/article/subscriber-badge-guide
/// [2]: https://help.twitch.tv/s/article/custom-bit-badges-guide
public struct GetChannelChatBadgesRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// An array of chat badge sets.
        @EmptyIfNull
        public private(set) var badgeSets: [BadgeSet]
        
        private enum CodingKeys: String, CodingKey {
            case badgeSets = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/chat/badges"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel Chat Badges request.
    ///
    /// - Parameter broadcasterId: The broadcaster whose chat badges are being requested.
    ///                            Must match the user ID in the user OAuth token.
    public init(broadcasterId: String) {
        queryParams = [(.broadcasterId, broadcasterId)]
    }
}
