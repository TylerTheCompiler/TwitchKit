//
//  DeleteEventSubSubscriptionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// Deletes an EventSub subscription.
public struct DeleteEventSubSubscriptionRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    
    public enum QueryParamKey: String {
        case id
    }
    
    public let method: HTTPMethod = .delete
    public let path = "/eventsub/subscriptions"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Delete EventSub Subscription request.
    ///
    /// - Parameter subscriptionId: The subscription ID for the subscription you want to delete.
    public init(subscriptionId: String) {
        queryParams = [(.id, subscriptionId)]
    }
}
