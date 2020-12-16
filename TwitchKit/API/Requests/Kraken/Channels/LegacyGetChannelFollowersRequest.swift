//
//  LegacyGetChannelFollowersRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of users who follow a specified channel, sorted by the date when they started following the
/// channel (newest first, unless specified otherwise).
public struct LegacyGetChannelFollowersRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of follows.
        public let follows: [LegacyFollow]
        
        /// Tells the server where to start fetching the next set of results, in a multi-page response.
        public let cursor: String?
        
        /// The total number of follows.
        public let total: Int?
        
        private enum CodingKeys: String, CodingKey {
            case follows
            case cursor = "_cursor"
            case total = "_total"
        }
    }
    
    public enum QueryParamKey: String {
        case limit
        case offset
        case cursor
        case direction
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel Followers legacy request.
    ///
    /// - Parameters:
    ///   - channelId: The channel ID of the channel whose followers to get.
    ///   - limit: Maximum number of objects to return. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0.
    ///   - cursor: Tells the server where to start fetching the next set of results, in a multi-page response.
    ///   - direction: Direction of sorting. Default: `.descending` (newest first).
    public init(channelId: String,
                limit: Int? = nil,
                offset: Int? = nil,
                cursor: String? = nil,
                direction: LegacySortDirection? = nil) {
        path = "/channels/\(channelId)/follows"
        queryParams = [
            (.limit, limit?.description),
            (.offset, offset?.description),
            (.cursor, cursor),
            (.direction, direction?.rawValue)
        ]
    }
}
