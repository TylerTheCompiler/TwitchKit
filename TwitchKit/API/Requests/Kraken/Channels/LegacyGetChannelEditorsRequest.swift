//
//  LegacyGetChannelEditorsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of users who are editors for a specified channel.
public struct LegacyGetChannelEditorsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of editor users.
        public let users: [LegacyUser]
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get Channel Editors legacy request.
    ///
    /// - Parameter channelId: The channel ID of the channel whose editors to get.
    public init(channelId: String) {
        path = "/channels/\(channelId)/editors"
    }
}
