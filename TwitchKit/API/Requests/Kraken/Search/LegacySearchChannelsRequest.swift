//
//  LegacySearchChannelsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Searches for channels based on a specified query parameter.
///
/// A channel is returned if the query parameter is matched entirely or partially,
/// in the channel description or game name.
public struct LegacySearchChannelsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The channels that satisfy the search query.
        public let channels: [LegacyChannel]
        
        /// The total number of returned channels.
        public let total: Int?
        
        private enum CodingKeys: String, CodingKey {
            case channels
            case total = "_total"
        }
    }
    
    public enum QueryParamKey: String {
        case query
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/search/channels"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Search Channels legacy request.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - limit: Maximum number of objects to return, sorted by number of followers. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0.
    public init(query: String, limit: Int? = nil, offset: Int? = nil) {
        queryParams = [
            (.query, query),
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
