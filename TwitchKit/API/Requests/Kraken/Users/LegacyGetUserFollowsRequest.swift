//
//  LegacyGetUserFollowsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of all channels followed by a specified user, sorted by the
/// date when they started following each channel.
public struct LegacyGetUserFollowsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The list of returned follows.
        public let follows: [LegacyFollow]
        
        /// The total number of returned follows.
        public let total: Int
        
        private enum CodingKeys: String, CodingKey {
            case follows
            case total = "_total"
        }
    }
    
    public enum Sort: String {
        case createdAt = "created_at"
        case lastBroadcast = "last_broadcast"
        case login
    }
    
    public enum QueryParamKey: String {
        case direction
        case sortBy = "sortby"
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get User Follows legacy request.
    ///
    /// - Parameters:
    ///   - userId: The user ID of the user whose followed channels to get.
    ///   - direction: Sorting direction. Default: `.descending` (newest first).
    ///   - sort: Sorting key. Default: `.createdAt`
    ///   - limit: Maximum number of most-recent objects to return. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0.
    public init(userId: String,
                direction: LegacySortDirection? = nil,
                sortBy sort: Sort? = nil,
                limit: Int? = nil,
                offset: Int? = nil) {
        path = "/users/\(userId)/follows/channels"
        queryParams = [
            (.direction, direction?.rawValue),
            (.sortBy, sort?.rawValue),
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
