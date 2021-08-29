//
//  GetUserBlockListRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/28/21.
//

/// Gets a specified user's block list.
///
/// The list is sorted by when the block occurred in descending order (i.e. most recent block first).
public struct GetUserBlockListRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The specified user's block list, sorted by most recent block first.
        public let users: [BlockedUser]
        
        private enum CodingKeys: String, CodingKey {
            case users = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case first
        case after
    }
    
    public let path = "/users/blocks"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get User Block List request.
    ///
    /// - Parameters broadcasterId: User ID for a Twitch user.
    public init(broadcasterId: String) {
        queryParams = [(.broadcasterId, broadcasterId)]
    }
    
    /// Creates a new Get User Block List pagination request.
    ///
    /// - Parameters:
    ///   - cursor: Cursor for forward pagination: tells the server where to start fetching the next set of
    ///             results, in a multi-page response. The cursor value specified here is from the pagination
    ///             response field of a prior query.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(after cursor: Pagination.Cursor, first: Int? = nil) {
        queryParams = [
            (.after, cursor.rawValue),
            (.first, first?.description)
        ]
    }
}
