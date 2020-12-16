//
//  LegacyGetChannelTeamsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of teams to which a specified channel belongs.
public struct LegacyGetChannelTeamsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of teams.
        public let teams: [LegacyTeam]
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get Channel Teams legacy request.
    ///
    /// - Parameter channelId: The channel ID of the channel whose teams to get.
    public init(channelId: String) {
        path = "/channels/\(channelId)/teams"
    }
}
