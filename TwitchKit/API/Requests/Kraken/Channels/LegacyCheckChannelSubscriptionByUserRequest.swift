//
//  LegacyCheckChannelSubscriptionByUserRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Checks if a specified channel has a specified user subscribed to it. Intended for use by channel owners.
///
/// Returns a subscription object which includes the user if that user is subscribed.
/// Requires authentication for the channel.
public struct LegacyCheckChannelSubscriptionByUserRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyChannelSubscription
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Check Channel Subscription By User legacy request.
    ///
    /// - Parameters:
    ///   - channelId: The channel ID of the channel to check subscriptions for.
    ///   - userId: The user ID of the user to check a subscription for.
    public init(channelId: String, userId: String) {
        path = "/channels/\(channelId)/subscriptions/\(userId)"
    }
}
