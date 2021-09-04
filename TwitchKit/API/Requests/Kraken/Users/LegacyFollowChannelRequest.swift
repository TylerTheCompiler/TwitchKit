//
//  LegacyFollowChannelRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Adds a specified user to the followers of a specified channel.
///
/// There is an error response (422 Unprocessable Entity) if the channel could not be followed.
public struct LegacyFollowChannelRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyFollow
    
    public enum QueryParamKey: String {
        case notifications
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .put
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Follow Channel legacy request.
    ///
    /// - Parameters:
    ///   - userId: The user ID of the user who will be following the channel.
    ///   - channelId: The channel ID of the channel to follow.
    ///   - turnOnNotifications: If true, the user gets email or push notifications (depending on the user's
    ///                          notification settings) when the channel goes live. Default: false.
    public init(userId: String, channelId: String, turnOnNotifications: Bool? = nil) {
        path = "/users/\(userId)/follows/channels/\(channelId)"
        queryParams = [(.notifications, turnOnNotifications?.description)]
    }
}
