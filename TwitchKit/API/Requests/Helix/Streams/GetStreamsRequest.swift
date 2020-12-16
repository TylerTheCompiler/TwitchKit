//
//  GetStreamsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets information about active streams.
///
/// Streams are returned sorted by number of current viewers, in descending order. Across multiple pages of results,
/// there may be duplicate or missing streams, as viewers join and leave streams.
public struct GetStreamsRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The returned list of streams.
        public let streams: [Stream]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case streams = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case before
        case first
        case gameId = "game_id"
        case language
        case userId = "user_id"
        case userLogin = "user_login"
    }
    
    public let path = "/streams"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Streams request.
    ///
    /// - Parameters:
    ///   - gameIds: Returns streams broadcasting a specified game ID. You can specify up to 100 IDs.
    ///   - userIds: Returns streams broadcast by one or more specified user IDs. You can specify up to 100 IDs.
    ///   - userLogins: Returns streams broadcast by one or more specified user login names. You can specify up to
    ///                 100 names.
    ///   - languages: Stream language. You can specify up to 100 languages.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(gameIds: [String] = [],
                userIds: [String] = [],
                userLogins: [String] = [],
                languages: [String] = [],
                first: Int? = nil) {
        queryParams = [
            (.first, first?.description)
        ] + gameIds.map {
            (.gameId, $0)
        } + userIds.map {
            (.userId, $0)
        } + userLogins.map {
            (.userLogin, $0)
        } + languages.map {
            (.language, $0)
        }
    }
    
    /// Creates a new Get Streams request.
    ///
    /// - Parameters:
    ///   - cursor: Cursor for forward pagination.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(cursor: Pagination.DirectedCursor, first: Int? = nil) {
        queryParams = [
            (.after, cursor.forwardRawValue),
            (.before, cursor.backwardRawValue),
            (.first, first?.description)
        ]
    }
}
