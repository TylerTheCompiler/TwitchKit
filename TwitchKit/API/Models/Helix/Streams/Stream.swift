//
//  Stream.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Object representing a Twitch live stream.
public struct Stream: Decodable {
    
    /// The type of stream (either live or not).
    public enum StreamType: String, Decodable {
        case live
        case error = ""
    }
    
    /// Stream ID.
    public let id: String
    
    /// ID of the user who is streaming.
    public let userId: String
    
    /// Display name corresponding to `userId`.
    public let userName: String
    
    /// ID of the game being played on the stream.
    public let gameId: String
    
    /// Name of the game being played.
    public let gameName: String
    
    /// Stream type: "live" or "" (in case of error).
    public let type: StreamType
    
    /// Stream title.
    public let title: String
    
    /// Number of viewers watching the stream at the time of the query.
    public let viewerCount: Int
    
    /// UTC timestamp of when the stream started.
    @InternetDate
    public private(set) var startedAt: Date
    
    /// Stream language.
    public let language: String
    
    /// Shows tag IDs that apply to the stream.
    public let tagIds: [String]
    
    /// Template thumbnail URL of the stream.
    public let thumbnailUrl: TemplateURL<ImageTemplateURLStrategy>
}
