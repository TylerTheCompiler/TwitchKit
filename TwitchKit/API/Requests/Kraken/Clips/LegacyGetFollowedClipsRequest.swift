//
//  LegacyGetFollowedClipsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets the top clips for the games followed by a specified user, identified by an OAuth token.
///
/// - Note: The clips service returns a maximum of 1000 clips.
public struct LegacyGetFollowedClipsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of followed clips.
        public let clips: [LegacyClip]
        
        /// Tells the server where to start fetching the next set of results, in a multi-page response.
        public let cursor: String?
        
        private enum CodingKeys: String, CodingKey {
            case clips
            case cursor = "_cursor"
        }
    }
    
    public enum QueryParamKey: String {
        case trending
        case limit
        case cursor
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/clips/followed"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Followed Clips legacy request.
    ///
    /// - Parameters:
    ///   - trending: If true, the clips returned are ordered by popularity; otherwise, by viewcount. Default: false.
    ///   - limit: Maximum number of most-recent objects to return. Default: 10. Maximum: 100.
    ///   - cursor: Tells the server where to start fetching the next set of results, in a multi-page response.
    public init(trending: Bool? = nil,
                limit: Int? = nil,
                cursor: String? = nil) {
        queryParams = [
            (.trending, trending?.description),
            (.limit, limit?.description),
            (.cursor, cursor)
        ]
    }
}
