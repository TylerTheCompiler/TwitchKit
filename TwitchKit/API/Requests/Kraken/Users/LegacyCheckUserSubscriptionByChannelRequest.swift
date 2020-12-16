//
//  LegacyCheckUserSubscriptionByChannelRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Checks if a specified user is subscribed to a specified channel.
///
/// There is an error response (422 Unprocessable Entity) if the channel does not have a subscription program.
public struct LegacyCheckUserSubscriptionByChannelRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// <#Description#>
        public let id: String
        
        /// <#Description#>
        public let subPlan: String
        
        /// <#Description#>
        public let subPlanName: String
        
        /// <#Description#>
        public let channel: LegacyChannel
        
        @InternetDate
        public private(set) var createdAt: Date // 2017-04-08T19:54:24Z
        
        private enum CodingKeys: String, CodingKey {
            case id = "_id"
            case subPlan
            case subPlanName
            case channel
            case createdAt
        }
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Check User Subscription By Channel legacy request.
    ///
    /// - Parameters:
    ///   - userId: The user ID of the user to check a subscription for.
    ///   - channelId: The channel ID of the channel to check a subscription for.
    public init(userId: String, channelId: String) {
        path = "/users/\(userId)/subscriptions/\(channelId)"
    }
}
