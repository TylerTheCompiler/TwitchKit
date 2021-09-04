//
//  GetStreamMarkersRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets a list of markers for either a specified user's most recent stream or a specified VOD/video (stream),
/// ordered by recency.
///
/// A marker is an arbitrary point in a stream that the broadcaster wants to mark; e.g., to easily return to later.
/// The only markers returned are those created by the user identified by the Bearer token.
public struct GetStreamMarkersRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of stream marker containers.
        public let streamMarkerContainers: [StreamMarkersContainer]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case streamMarkerContainers = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case before
        case first
        case userId = "user_id"
        case videoId = "video_id"
    }
    
    public let path = "/streams/markers"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Stream Markers request for a give broadcaster.
    ///
    /// - Parameters:
    ///   - userId: ID of the broadcaster from whose stream markers are returned.
    ///   - first: Number of values to be returned. Limit: 100. Default: 20.
    public init(userId: String, first: Int? = nil) {
        queryParams = [
            (.userId, userId),
            (.first, first?.description)
        ]
    }
    
    /// Creates a new Get Stream Markers request for a give video ID.
    ///
    /// - Parameters:
    ///   - videoId: ID of the VOD/video whose stream markers are returned.
    ///   - first: Number of values to be returned. Limit: 100. Default: 20.
    public init(videoId: String, first: Int? = nil) {
        queryParams = [
            (.videoId, videoId),
            (.first, first?.description)
        ]
    }
    
    /// Creates a new Get Stream Markers request.
    ///
    /// - Parameters:
    ///   - cursor: Cursor for forward/backward pagination.
    ///   - first: Number of values to be returned. Limit: 100. Default: 20.
    public init(cursor: Pagination.DirectedCursor, first: Int? = nil) {
        queryParams = [
            (.after, cursor.forwardRawValue),
            (.before, cursor.backwardRawValue),
            (.first, first?.description)
        ]
    }
}
