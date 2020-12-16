//
//  ChannelInformation.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Information about a Twitch channel.
public struct ChannelInformation: Decodable {
    
    /// Twitch User ID of this channel owner.
    public let broadcasterId: String
    
    /// Username of this channel owner.
    public let broadcasterName: String
    
    /// Language of the channel.
    public let broadcasterLanguage: String
    
    /// Current game ID being played on the channel.
    public let gameId: String
    
    /// Name of the game being played on the channel.
    public let gameName: String
    
    /// Title of the stream.
    public let title: String
}
