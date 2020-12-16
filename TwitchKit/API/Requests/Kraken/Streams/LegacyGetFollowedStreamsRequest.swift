//
//  LegacyGetFollowedStreamsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of online streams a user is following, based on a specified OAuth token.
public struct LegacyGetFollowedStreamsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of streams the current user is following.
        public let streams: [LegacyStream]
    }
    
    /// The type of live stream to return.
    public enum StreamType: String {
        case live
        case playlist
        case all
    }
    
    public enum QueryParamKey: String {
        case streamType = "stream_type"
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/streams/followed"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Followed Streams legacy request.
    ///
    /// - Parameters:
    ///   - streamType: Constrains the type of streams returned. Playlists are offline streams of VODs
    ///                 (Video on Demand) that appear live. Default: live.
    ///   - limit: Maximum number of objects to return. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0. Capped at 900.
    public init(streamType: StreamType? = nil,
                limit: Int? = nil,
                offset: Int? = nil) {
        queryParams = [
            (.streamType, streamType?.rawValue),
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
