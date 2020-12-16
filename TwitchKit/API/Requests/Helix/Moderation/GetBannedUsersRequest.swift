//
//  GetBannedUsersRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Returns all banned and timed-out users in a channel.
public struct GetBannedUsersRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of banned users.
        public let users: [BannedUser]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case users = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case before
        case broadcasterId = "broadcaster_id"
        case userId = "user_id"
    }
    
    public let path = "/moderation/banned"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Banned Users request for a set of user IDs.
    ///
    /// - Parameter userIds: Filters the results and only returns a status object for users who are banned in this
    ///                      channel and have a matching user ID. Max: 100.
    public init(userIds: [String] = []) {
        self.init(userIds: userIds, cursor: nil)
    }
    
    /// Creates a new Get Banned Users request with the pagination cursor.
    ///
    /// - Parameter cursor: Cursor for forward or backward pagination.
    public init(cursor: Pagination.DirectedCursor) {
        self.init(userIds: [], cursor: cursor)
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
    
    // MARK: - Private
    
    private init(userIds: [String], cursor: Pagination.DirectedCursor?) {
        queryParams = [
            (.after, cursor?.forwardRawValue),
            (.before, cursor?.backwardRawValue)
        ] + userIds.map {
            (.userId, $0)
        }
    }
}
