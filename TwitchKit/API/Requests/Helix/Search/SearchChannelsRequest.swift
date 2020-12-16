//
//  SearchChannelsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Returns a list of channels (users who have streamed within the past 6 months) that match the query via channel
/// name or description either entirely or partially.
///
/// Results include both live and offline channels. Online channels will have additional metadata (e.g. `startedAt`,
/// `tagIds`).
public struct SearchChannelsRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The returned list of channels.
        public let channels: [Channel]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case channels = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case first
        case liveOnly = "live_only"
        case query
    }
    
    public let path = "/search/channels"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Search Channels request.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - liveOnly: Filter results for live streams only. Default: false.
    ///   - after: Cursor for forward pagination.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20
    public init(query: String,
                liveOnly: Bool? = nil,
                after: Pagination.Cursor? = nil,
                first: Int? = nil) {
        queryParams = [
            (.query, query),
            (.liveOnly, liveOnly?.description),
            (.after, after?.rawValue),
            (.first, first?.description)
        ]
    }
}
