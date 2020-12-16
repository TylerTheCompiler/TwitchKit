//
//  LegacySearchStreamsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Searches for streams based on a specified query parameter.
///
/// A stream is returned if the query parameter is matched entirely or partially,
/// in the channel description or game name.
public struct LegacySearchStreamsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The streams that satisfy the search query.
        public let streams: [LegacyStream]
        
        /// The total number of returned channels.
        public let total: Int?
        
        private enum CodingKeys: String, CodingKey {
            case streams
            case total = "_total"
        }
    }
    
    public enum QueryParamKey: String {
        case query
        case limit
        case offset
        case hls
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .get
    public let path = "/search/streams"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Search Streams legacy request.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - onlyHLS: If true, returns only HLS streams. If false, only RTMP streams. If nil, both HLS and RTMP streams.
    ///              HLS is HTTP Live Streaming, a live-streaming communications protocol. RTMP is Real-Time Media
    ///              Protocol, an industry standard for moving video around a network. Default: nil.
    ///   - limit: Maximum number of objects to return, sorted by number of current viewers. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0.
    public init(query: String,
                onlyHLS: Bool? = nil,
                limit: Int? = nil,
                offset: Int? = nil) {
        queryParams = [
            (.query, query),
            (.hls, onlyHLS?.description),
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
