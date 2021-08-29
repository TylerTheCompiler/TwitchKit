//
//  CheckUserSubscriptionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/28/21.
//

/// Checks if a specific user (`userId`) is subscribed to a specific channel (`broadcasterId`).
public struct CheckUserSubscriptionRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The user's subscription to the broadcaster.
        @ArrayOfOne
        public private(set) var subscription: BroadcasterSubscription
        
        private enum CodingKeys: String, CodingKey {
            case subscription = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case userId = "user_id"
    }
    
    public let path = "/subscriptions/user"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Check User Subscription request.
    ///
    /// - Parameters:
    ///   - broadcasterId: User ID of an Affiliate or Partner broadcaster.
    ///   - userId: User ID of a Twitch viewer.
    public init(broadcasterId: String, userId: String) {
        queryParams = [
            (.broadcasterId, broadcasterId),
            (.userId, userId)
        ]
    }
}
