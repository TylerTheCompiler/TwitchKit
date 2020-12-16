//
//  GetEventSubSubscriptionsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// Gets a list of your EventSub subscriptions.
public struct GetEventSubSubscriptionsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// Array containing 1 element: the created subscription.
        public let subscriptions: [EventSub.Subscription]
        
        /// Subscription limit for client id that made the subscription creation request.
        public let limit: Int
        
        /// Total number of subscriptions for the client ID that made the subscription creation request.
        public let total: Int
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case subscriptions = "data"
            case limit
            case total
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case status
        case after
    }
    
    public let path = "/eventsub/subscriptions"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get EventSub Subscriptions request.
    ///
    /// - Parameter status: Include this parameter to filter subscriptions by their status.
    public init(status: EventSub.Subscription.Status? = nil) {
        queryParams = [(.status, status?.rawValue)]
    }
    
    /// Creates a new Get EventSub Subscriptions request for obtaining the next set of results in a paginated response.
    ///
    /// - Parameter after: A cursor value to be used in a subsequent request to specify the starting point of the next
    ///                    set of results.
    public init(after: Pagination.Cursor) {
        queryParams = [(.after, after.rawValue)]
    }
}
