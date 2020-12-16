//
//  LegacyGetCollectionsByChannelRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets all collections owned by a specified channel.
///
/// Collections are sorted by update date, with the most recently updated first.
public struct LegacyGetCollectionsByChannelRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of collections.
        public let collections: [LegacyCollection]
        
        /// Tells the server where to start fetching the next set of results in a multi-page response.
        public let cursor: String?
        
        private enum CodingKeys: String, CodingKey {
            case collections
            case cursor = "_cursor"
        }
    }
    
    public enum QueryParamKey: String {
        case containingItem = "containing_item"
        case limit
        case cursor
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Collections By Channel legacy request.
    ///
    /// - Parameters:
    ///   - channelId: The channel ID of the channel whose collections to get.
    ///   - videoId: Returns only collections containing the specified video. Note this uses a video ID, not a
    ///              collection item ID.
    ///   - limit: Maximum number of most-recent objects to return. Default: 10. Maximum: 100.
    ///   - cursor: Tells the server where to start fetching the next set of results in a multi-page response.
    public init(channelId: String,
                containingVideoWithId videoId: String? = nil,
                limit: Int? = nil,
                cursor: String? = nil) {
        path = "/channels/\(channelId)/collections"
        queryParams = [
            (.containingItem, videoId.map { "video:\($0)" }),
            (.limit, limit?.description),
            (.cursor, cursor)
        ]
    }
}
