//
//  LegacyGetCurrentChannelRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a channel object based on a specified OAuth token.
///
/// Get Current Channel returns more data than Get Channel by ID because Get Current Channel is privileged.
public struct LegacyGetCurrentChannelRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyCurrentChannel
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/channel"
    
    /// Creates a new Get Current Channel legacy request.
    public init() {}
}
