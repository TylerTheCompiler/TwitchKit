//
//  Channel.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A Twitch channel as returned from a search endpoint.
public struct Channel: Decodable {
    
    /// Channel language (Broadcaster Language field from the Channels service).
    public let broadcasterLanguage: String
    
    /// Display name corresponding to `userId`.
    public let displayName: String
    
    /// ID of the game being played on the stream.
    public let gameId: String
    
    /// Channel ID.
    public let id: String
    
    /// Whether the channel is currently live or not.
    public let isLive: Bool
    
    /// Shows tag IDs that apply to the stream (live only).
    public let tagsIds: [String]
    
    /// Template thumbnail URL of the stream.
    public let thumbnailUrl: TemplateURL<ImageTemplateURLStrategy>
    
    /// Channel title.
    public let title: String
    
    /// UTC timestamp. (live only)
    @OptionalInternetDate
    public private(set) var startedAt: Date?
}
