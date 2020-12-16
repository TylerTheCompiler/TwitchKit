//
//  GetHypeTrainEventsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets the information of the most recent Hype Train of the given channel ID.
///
/// When there is currently an active Hype Train, it returns information about that Hype Train. When there is
/// currently no active Hype Train, it returns information about the most recent Hype Train. After 5 days, if no
/// Hype Train has been active, the endpoint will return an empty response.
public struct GetHypeTrainEventsRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The returned list of Hype Train events.
        public let events: [HypeTrainEvent]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case events = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case cursor
        case first
        case id
    }
    
    public let path = "/hypetrain/events"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Hype Train Events request for a specified event ID.
    ///
    /// - Parameters:
    ///   - broadcasterId: User ID of the broadcaster. Must match the User ID in the Bearer token if User Token is used.
    ///   - eventId: The id of the wanted event.
    public init(broadcasterId: String? = nil, eventId: String) {
        self.init(broadcasterId: broadcasterId,
                  eventId: eventId,
                  after: nil,
                  first: nil)
    }
    
    /// Creates a new Get Hype Train Events request.
    ///
    /// - Parameters:
    ///   - broadcasterId: User ID of the broadcaster. Must match the User ID in the Bearer token if User Token is used.
    ///   - after: Cursor for forward pagination.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 1.
    public init(broadcasterId: String? = nil,
                after: Pagination.Cursor? = nil,
                first: Int? = nil) {
        self.init(broadcasterId: broadcasterId,
                  eventId: nil,
                  after: after,
                  first: first)
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
    
    // MARK: - Private
    
    private init(broadcasterId: String?,
                 eventId: String?,
                 after: Pagination.Cursor?,
                 first: Int?) {
        queryParams = [
            (.broadcasterId, broadcasterId),
            (.id, eventId),
            (.cursor, after?.rawValue),
            (.first, first?.description)
        ]
    }
}
