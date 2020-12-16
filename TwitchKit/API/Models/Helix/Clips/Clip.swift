//
//  Clip.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Metadata of a Twitch video clip.
public struct Clip: Decodable {
    
    /// ID of the clip being queried.
    public let id: String
    
    /// URL where the clip can be viewed.
    @SafeURL
    public private(set) var url: URL?
    
    /// URL to embed the clip.
    @SafeURL
    public private(set) var embedUrl: URL?
    
    /// User ID of the stream from which the clip was created.
    public let broadcasterId: String
    
    /// Display name corresponding to `broadcasterId`.
    public let broadcasterName: String
    
    /// ID of the user who created the clip.
    public let creatorId: String
    
    /// Display name corresponding to `creatorId`.
    public let creatorName: String
    
    /// ID of the video from which the clip was created.
    public let videoId: String
    
    /// ID of the game assigned to the stream when the clip was created.
    public let gameId: String
    
    /// Language of the stream from which the clip was created.
    public let language: String
    
    /// Title of the clip.
    public let title: String
    
    /// Number of times the clip has been viewed.
    public let viewCount: Int
    
    /// Date when the clip was created.
    @InternetDate
    public private(set) var createdAt: Date
    
    /// URL of the clip thumbnail.
    @SafeURL
    public private(set) var thumbnailUrl: URL?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case url = "URL"
        case embedUrl
        case broadcasterId
        case broadcasterName
        case creatorId
        case creatorName
        case videoId
        case gameId
        case language
        case title
        case viewCount
        case createdAt
        case thumbnailUrl
    }
}
