//
//  LegacyStream.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyStream: Decodable {
    
    /// <#Description#>
    public let id: Int
    
    /// <#Description#>
    public let averageFPS: Double
    
    /// <#Description#>
    public let channel: LegacyChannel
    
    /// <#Description#>
    public let delay: Int
    
    /// <#Description#>
    public let game: String
    
    /// <#Description#>
    public let isPlaylist: Bool
    
    /// <#Description#>
    public let preview: LegacyThumbnails
    
    /// <#Description#>
    public let videoHeight: Int
    
    /// <#Description#>
    public let viewers: Int
    
    /// <#Description#>
    @InternetDate
    public private(set) var createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case averageFPS = "averageFps"
        case channel
        case delay
        case game
        case isPlaylist
        case preview
        case videoHeight
        case viewers
        case createdAt
    }
}
