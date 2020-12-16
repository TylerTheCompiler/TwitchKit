//
//  LegacyResetChannelStreamKeyRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Deletes the stream key for a specified channel. Once it is deleted, the stream key is automatically reset.
///
/// A stream key, also known as authorization key, uniquely identifies a stream. Each broadcast uses an RTMP URL
/// that includes the stream key. Stream keys are assigned by Twitch.
public struct LegacyResetChannelStreamKeyRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyChannel
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .delete
    public let path: String
    
    /// Creates a new Reset Channel Stream Key legacy request.
    ///
    /// - Parameter channelId: The channel ID of the channel whose stream key to reset.
    public init(channelId: String) {
        path = "/channels/\(channelId)/stream_key"
    }
}
