//
//  LegacyUnfollowChannelRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Deletes a specified user from the followers of a specified channel.
public struct LegacyUnfollowChannelRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .delete
    public let path: String
    
    /// Creates a new Unfollow Channel legacy request.
    ///
    /// - Parameters:
    ///   - userId: The user ID of the user who will be unfollowing the channel.
    ///   - channelId: The channel ID of the channel to unfollow.
    public init(userId: String, channelId: String) {
        path = "/users/\(userId)/follows/channels/\(channelId)"
    }
}
