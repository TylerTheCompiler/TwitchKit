//
//  GetFollowedStreamsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets information about active streams belonging to channels that the authenticated user follows.
///
/// Streams are returned sorted by number of current viewers, in descending order. Across multiple pages of
/// results, there may be duplicate or missing streams, as viewers join and leave streams.
public struct GetFollowedStreamsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
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
        case first
        case userId = "user_id"
    }
    
    public let path = "/streams/followed"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Followed Streams request for the authenticated user.
    public init() {
        queryParams = []
    }
    
    /// Creates a new Get Followed Streams pagination request.
    ///
    /// - Parameters:
    ///   - cursor: Cursor for forward pagination.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 100.
    public init(cursor: Pagination.DirectedCursor, first: Int? = nil) {
        queryParams = [
            (.after, cursor.forwardRawValue),
            (.first, first?.description)
        ]
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .userId, of: &queryParams, with: userId)
    }
}
