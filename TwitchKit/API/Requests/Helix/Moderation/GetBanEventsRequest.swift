//
//  GetBanEventsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Returns all user bans and un-bans in a channel.
public struct GetBanEventsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of ban events.
        public let events: [BanEvent]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case events = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case broadcasterId = "broadcaster_id"
        case first
        case userId = "user_id"
    }
    
    public let path = "/moderation/banned/events"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Ban Events request for the specified user IDs.
    ///
    /// - Parameter userIds: Filters the results and only returns a status object for users who are banned in this
    ///                      channel and have a matching user ID. Max: 100.
    public init(userIds: [String] = []) {
        self.init(userIds: userIds, after: nil, first: nil)
    }
    
    /// Creates a new Get Ban Events request.
    ///
    /// - Parameters:
    ///   - after: Cursor for forward pagination.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(after: Pagination.Cursor, first: Int? = nil) {
        self.init(userIds: [], after: after, first: nil)
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
    
    // MARK: - Private
    
    private init(userIds: [String], after: Pagination.Cursor?, first: Int?) {
        queryParams = [
            (.after, after?.rawValue),
            (.first, first?.description)
        ] + userIds.map {
            (.userId, $0)
        }
    }
}
