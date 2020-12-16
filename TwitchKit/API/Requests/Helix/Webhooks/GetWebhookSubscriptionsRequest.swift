//
//  GetWebhookSubscriptionsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Gets the Webhook subscriptions of a user identified by a Bearer token, in order of expiration.
public struct GetWebhookSubscriptionsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of webhook subscriptions.
        public let webhookSubscription: [WebhookSubscription]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        /// A hint at the total number of results returned, on all pages. This is an approximation: as you page
        /// through the list, some subscriptions may expire and others may be added.
        public let total: Int
        
        private enum CodingKeys: String, CodingKey {
            case webhookSubscription = "data"
            case cursor = "pagination"
            case total
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case first
    }
    
    public let path = "/webhooks/subscriptions"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Webhook Subscriptions request.
    ///
    /// - Parameters:
    ///   - after: Cursor for forward pagination.
    ///   - first: Number of values to be returned per page. Limit: 100. Default: 20.
    public init(after: Pagination.Cursor? = nil,
                first: Int? = nil) {
        queryParams = [
            (.after, after?.rawValue),
            (.first, first?.description)
        ]
    }
}
