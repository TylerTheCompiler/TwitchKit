//
//  LegacyGetChannelByIdRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a specified channel object.
public struct LegacyGetChannelByIdRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyChannel
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get Channel By Id legacy request.
    ///
    /// - Parameter channelId: The channel ID of the channel to get.
    public init(channelId: String) {
        path = "/channels/\(channelId)"
    }
}
