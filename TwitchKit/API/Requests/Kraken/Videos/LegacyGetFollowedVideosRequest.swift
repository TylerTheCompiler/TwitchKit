//
//  LegacyGetFollowedVideosRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets the videos from channels followed by a user, based on a specified OAuth token.
public struct LegacyGetFollowedVideosRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of videos.
        public let videos: [LegacyVideo]
    }
    
    /// Determines the sort order of the returned list of videos.
    public enum Sort: String {
        
        /// Videos are sorted by publication time, most recent first.
        case time
        
        /// Videos are sorted by view count, in descending order.
        case views
    }
    
    public enum QueryParamKey: String {
        case broadcastType = "broadcast_type"
        case language
        case sort
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/videos/followed"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Followed Videos legacy request.
    ///
    /// - Parameters:
    ///   - broadcastTypes: Constrains the type of videos returned. Default: all types (no filter).
    ///   - languages: Constrains the languages of videos returned. Examples: "es", "en", "es", "th".
    ///                If no language is specified, all languages are returned. Default: all languages.
    ///   - sort: Determines the sort order of the returned list of videos.
    ///   - limit: Maximum number of objects to return. Default: 10. Maximum: 100.
    ///   - offset: Object offset for pagination of reults. Default: 0. Maximum: 500.
    public init(broadcastTypes: [LegacyVideo.BroadcastType] = [],
                languages: [String] = [],
                sort: Sort? = nil,
                limit: Int? = nil,
                offset: Int? = nil) {
        queryParams = [
            (.broadcastType, broadcastTypes.map(\.rawValue).joined(separator: ",")),
            (.language, languages.joined(separator: ",")),
            (.sort, sort?.rawValue),
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
