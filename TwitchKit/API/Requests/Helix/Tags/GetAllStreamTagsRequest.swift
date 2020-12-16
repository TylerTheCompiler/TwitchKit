//
//  GetAllStreamTagsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// Gets the list of all stream tags defined by Twitch, optionally filtered by tag ID(s).
///
/// The response has a payload with a `tags` array of `StreamTag` elements and a `pagination` value containing
/// information required to query for more tags.
public struct GetAllStreamTagsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned array of stream tags.
        public let tags: [StreamTag]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        ///
        /// Not supported when one or more tag IDs are provided in the request.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case tags = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case first
        case tagId = "tag_id"
    }
    
    public let path = "/tags/streams"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get All Stream Tags request.
    ///
    /// - Parameters:
    ///   - tagIds: IDs of tags to return. Maximum of 100.
    ///   - first: Maximum number of tags to return. Maximum: 100. Default: 20.
    public init(tagIds: [String] = [], first: Int? = nil) {
        queryParams = [
            (.first, first?.description)
        ] + tagIds.map {
            (.tagId, $0)
        }
    }
    
    /// Creates a new Get All Stream Tags request.
    ///
    /// - Parameters:
    ///   - after: Cursor for forward pagination; tells the server where to start fetching the next set of
    ///            results in a multi-page response. The cursor value specified here is from the
    ///            `ResponseBody.pagination` of a prior request.
    ///   - first: Maximum number of tags to return. Maximum: 100. Default: 20.
    public init(after: Pagination.Cursor, first: Int? = nil) {
        queryParams = [
            (.after, after.rawValue),
            (.first, first?.description)
        ]
    }
}
