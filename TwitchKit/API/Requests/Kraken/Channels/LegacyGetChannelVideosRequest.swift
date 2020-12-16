//
//  LegacyGetChannelVideosRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of VODs (Video on Demand) from a specified channel.
public struct LegacyGetChannelVideosRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of videos.
        public let videos: [LegacyVideo]
        
        /// The total number of videos returned.
        public let total: Int?
        
        private enum CodingKeys: String, CodingKey {
            case videos
            case total = "_total"
        }
    }
    
    /// Sorting order of the returned videos.
    public enum Sort: String {
        
        /// The videos are sorted by most number of views first.
        case views
        
        /// The videos are sorted by most recent first.
        case time
    }
    
    public enum QueryParamKey: String {
        case limit
        case offset
        case broadcastType = "broadcast_type"
        case language
        case sort
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel Videos legacy request.
    ///
    /// - Parameters:
    ///   - channelId: The channel ID of the channel from which to fetch videos.
    ///   - limit: Maximum number of objects to return. Default: 10. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0.
    ///   - broadcastTypes: Constrains the type of videos returned. Default: all types (an empty array).
    ///   - languages: Constrains the language of the videos that are returned; for example, "en", "es".
    ///                Default: all languages (an empty array).
    ///   - sort: Sorting order of the returned objects. Default: time (most recent first).
    public init(channelId: String,
                limit: Int? = nil,
                offset: Int? = nil,
                broadcastTypes: [LegacyVideo.BroadcastType] = [],
                languages: [String] = [],
                sort: Sort? = nil) {
        path = "/channels/\(channelId)/videos"
        queryParams = [
            (.limit, limit?.description),
            (.offset, offset?.description),
            (.broadcastType, broadcastTypes.map(\.rawValue).joined(separator: ",")),
            (.language, languages.joined(separator: ",")),
            (.sort, sort?.rawValue)
        ]
    }
}
