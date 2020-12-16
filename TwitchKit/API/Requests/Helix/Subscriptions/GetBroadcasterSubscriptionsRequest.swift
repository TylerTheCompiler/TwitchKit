//
//  GetBroadcasterSubscriptionsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Get all of a broadcaster’s subscriptions.
public struct GetBroadcasterSubscriptionsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of broadcaster subscriptions.
        public let subscriptions: [BroadcasterSubscription]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case subscriptions = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case userId = "user_id"
    }
    
    public let path = "/subscriptions"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Broadcaster Subscriptions request.
    ///
    /// - Parameter userIds: Unique identifiers of accounts to get subscription status of. Accepts up to 100 values.
    public init(userIds: [String] = []) {
        queryParams = userIds.map { (.userId, $0) }
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
