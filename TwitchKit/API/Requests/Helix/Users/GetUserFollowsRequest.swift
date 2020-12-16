//
//  GetUserFollowsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Gets information on follow relationships between two Twitch users.
///
/// This can return information like “who is qotrok following,” “who is following qotrok,” or “is user X following
/// user Y.” Information returned is sorted in order, most recent follow first.
public struct GetUserFollowsRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The returned list of user follows.
        public let userFollows: [UserFollow]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        /// Total number of items returned.
        ///
        /// * If only `fromId` was in the request, this is the total number of followed users.
        /// * If only `toId` was in the request, this is the total number of followers.
        /// * If both `fromId` and `toId` were in the request, this is 1 (if the "from" user follows
        ///   the "to" user) or 0.
        public let total: Int
        
        private enum CodingKeys: String, CodingKey {
            case userFollows = "data"
            case cursor = "pagination"
            case total
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case first
        case fromId = "from_id"
        case toId = "to_id"
    }
    
    public let path = "/users/follows"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get User Follows request.
    ///
    /// - Parameters:
    ///   - fromId: User ID. The request returns information about users who are being followed by the `fromId` user.
    ///   - toId: User ID. The request returns information about users who are following the `toId` user.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(fromId: String,
                toId: String? = nil,
                first: Int? = nil) {
        self.init(fromId: fromId,
                  toId: toId,
                  after: nil,
                  first: first)
    }
    
    /// Creates a new Get User Follows request.
    ///
    /// - Parameters:
    ///   - toId: User ID. The request returns information about users who are following the `toId` user.
    ///   - fromId: User ID. The request returns information about users who are being followed by the `fromId` user.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(toId: String,
                fromId: String? = nil,
                first: Int? = nil) {
        self.init(fromId: fromId,
                  toId: toId,
                  after: nil,
                  first: first)
    }
    
    /// Creates a new Get User Follows request using a pagination cursor.
    ///
    /// - Parameters:
    ///   - after: Cursor for forward pagination.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(after: Pagination.Cursor,
                first: Int? = nil) {
        self.init(fromId: nil,
                  toId: nil,
                  after: after,
                  first: first)
    }
    
    // MARK: - Private
    
    private init(fromId: String?,
                 toId: String?,
                 after: Pagination.Cursor?,
                 first: Int?) {
        queryParams = [
            (.fromId, fromId),
            (.toId, toId),
            (.after, after?.rawValue),
            (.first, first?.description)
        ]
    }
}
