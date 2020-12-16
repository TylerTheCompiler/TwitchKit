//
//  LegacyCheckUserFollowsByChannelRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Checks if a specified user follows a specified channel.
///
/// If the user is following the channel, a follow object is returned.
public struct LegacyCheckUserFollowsByChannelRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyFollow
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Check User Follows By Channel legacy request.
    ///
    /// - Parameters:
    ///   - userId: The user ID of the user to check.
    ///   - channelId: The channel ID of the channel to check to see if the user is following.
    public init(userId: String, channelId: String) {
        path = "/users/\(userId)/follows/channels/\(channelId)"
    }
}
