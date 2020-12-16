//
//  LegacyGetChannelSubscribersRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of users subscribed to a specified channel, sorted by the date when they subscribed.
///
/// If a user in the subscribers list has been banned, the subscription information will still be
/// provided, but the user object will have a value of null.
public struct LegacyGetChannelSubscribersRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of subscriptions.
        public let subscriptions: [LegacyChannelSubscription]
        
        /// The total number of subscriptions.
        public let total: Int?
        
        private enum CodingKeys: String, CodingKey {
            case subscriptions
            case total = "_total"
        }
    }
    
    public enum QueryParamKey: String {
        case limit
        case offset
        case direction
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel Subscribers legacy request.
    ///
    /// - Parameters:
    ///   - channelId: The channel ID of the channel whose subscribers to get.
    ///   - limit: Maximum number of objects to return. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0.
    ///   - direction: Sorting direction. Default: `.ascending` (oldest first).
    public init(channelId: String,
                limit: Int? = nil,
                offset: Int? = nil,
                direction: LegacySortDirection? = nil) {
        path = "/channels/\(channelId)/subscriptions"
        queryParams = [
            (.limit, limit?.description),
            (.offset, offset?.description),
            (.direction, direction?.rawValue)
        ]
    }
}
