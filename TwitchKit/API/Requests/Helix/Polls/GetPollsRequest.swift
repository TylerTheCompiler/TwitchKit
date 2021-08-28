//
//  GetPollsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

/// Gets information about all polls or specific polls for a Twitch channel.
///
/// Poll information is available for 90 days.
public struct GetPollsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// An array of polls in a specific channel.
        public let polls: [Poll]
        
        /// A cursor value to be used in a subsequent request to specify the
        /// starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            polls = try container.decodeIfPresent([Poll].self, forKey: .polls) ?? []
            _cursor = try container.decode(Pagination.self, forKey: .cursor)
        }
        
        private enum CodingKeys: String, CodingKey {
            case polls = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case id
        case after
        case first
    }
    
    public let path = "/polls"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Polls request for the polls identified by the given poll IDs, for the broadcaster identified
    /// by the user ID in the user auth token.
    ///
    /// - Parameters:
    ///   - pollIds: IDs of the polls to return. Filters results to one or more specific polls. Not providing one
    ///              or more IDs will return the full list of polls for the authenticated channel.
    ///   - first: Maximum number of objects to return. Maximum: 20. Default: 20.
    public init(pollIds: [String] = [], first: Int = 20) {
        queryParams = [(.first, first.description)] + pollIds.map { (.id, $0) }
    }
    
    /// Creates a new Get Polls request for the polls identified by the given poll IDs, for the broadcaster identified
    /// by the user ID in the user auth token.
    ///
    /// - Parameters:
    ///   - cursor: Cursor for forward pagination: tells the server where to start fetching the next set of results in a
    ///             multi-page response. The cursor value specified here is from the pagination response field of a prior
    ///             query.
    ///   - first: Maximum number of objects to return. Maximum: 20. Default: 20.
    public init(after cursor: Pagination.Cursor, first: Int = 20) {
        queryParams = [
            (.after, cursor.rawValue),
            (.first, first.description)
        ]
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
