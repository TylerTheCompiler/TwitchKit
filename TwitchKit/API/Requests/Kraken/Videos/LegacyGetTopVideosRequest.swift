//
//  LegacyGetTopVideosRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets the top videos based on viewcount, optionally filtered by game or time period.
public struct LegacyGetTopVideosRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of videos.
        public let vods: [LegacyVideo]
    }
    
    /// Specifies the window of time to search.
    public enum Period: String {
        case week
        case month
        case all
    }
    
    /// Determines the sort order of the returned list of videos.
    public enum Sort: String {
        
        /// Videos are sorted by publication time, most recent first.
        case time
        
        /// Videos are sorted by view count, in descending order.
        case views
    }
    
    public enum QueryParamKey: String {
        case game
        case broadcastType = "broadcast_type"
        case language
        case period
        case sort
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/videos/top"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Top Videos legacy request.
    ///
    /// - Parameters:
    ///   - game: Constrains videos by game. A game name can be retrieved using the Search Games endpoint.
    ///   - broadcastTypes: Constrains the type of videos returned. Default: all types (no filter).
    ///   - languages: Constrains the languages of videos returned. Examples: "es", "en", "es", "th".
    ///                If no language is specified, all languages are returned. Default: all languages.
    ///   - period: Specifies the window of time to search. Default: `.week`.
    ///   - sort: Determines the sort order of the returned list of videos.
    ///   - limit: Maximum number of objects to return. Default: 10. Maximum: 100.
    ///   - offset: Object offset for pagination of reults. Default: 0. Maximum: 500.
    public init(game: String? = nil,
                broadcastTypes: [LegacyVideo.BroadcastType] = [],
                languages: [String] = [],
                period: Period? = nil,
                sort: Sort? = nil,
                limit: Int? = nil,
                offset: Int? = nil) {
        queryParams = [
            (.game, game),
            (.broadcastType, broadcastTypes.map(\.rawValue).joined(separator: ",")),
            (.language, languages.joined(separator: ",")),
            (.period, period?.rawValue),
            (.sort, sort?.rawValue),
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
