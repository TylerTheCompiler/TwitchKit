//
//  LegacyGetFeaturedStreamsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of all featured live streams.
public struct LegacyGetFeaturedStreamsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of featured streams.
        public let streams: [LegacyStream]
        
        private enum CodingKeys: String, CodingKey {
            case streams = "featured"
        }
    }
    
    public enum QueryParamKey: String {
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/streams/featured"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Featured Streams legacy request.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of objects to return, sorted by priority. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0.
    public init(limit: Int? = nil, offset: Int? = nil) {
        queryParams = [
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
