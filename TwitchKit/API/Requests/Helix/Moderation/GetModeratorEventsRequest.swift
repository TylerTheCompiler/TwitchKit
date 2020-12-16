//
//  GetModeratorEventsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Returns a list of moderators or users added and removed as moderators from a channel.
public struct GetModeratorEventsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of moderator add/remove events.
        public let events: [ModeratorEvent]
        
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
        case userId = "user_id"
    }
    
    public let path = "/moderation/moderators/events"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Moderator Events request for the specified user IDs.
    ///
    /// - Parameter userIds: Filters the results and only returns an event object for users who are moderators in this
    ///                      channel and have a matching user ID. Max: 100.
    public init(userIds: [String] = []) {
        self.init(userIds: userIds, after: nil)
    }
    
    /// Creates a new Get Moderator Events request.
    ///
    /// - Parameters:
    ///   - after: Cursor for forward pagination.
    public init(after: Pagination.Cursor) {
        self.init(userIds: [], after: after)
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
    
    // MARK: - Private
    
    private init(userIds: [String], after: Pagination.Cursor?) {
        queryParams = [
            (.after, after?.rawValue)
        ] + userIds.map {
            (.userId, $0)
        }
    }
}
