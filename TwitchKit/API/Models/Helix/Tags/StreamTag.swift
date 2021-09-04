//
//  StreamTag.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Tags are used to describe a live stream beyond the game or category being broadcast. Viewers can
/// use tags to find streams they're interested in watching by filtering streams within a directory,
/// searching for specific tags, or when they're browsing front page recommendations.
public struct StreamTag: Decodable {
    
    /// ID of the tag.
    public let tagId: String
    
    /// true if the tag is auto-generated; otherwise, false . An auto-generated tag is one automatically
    /// applied by Twitch (e.g., a language tag based on the broadcaster's settings); these tags cannot
    /// be added or removed by the user.
    public let isAuto: Bool
    
    /// All localized names of the tag.
    public let localizationNames: [String: String]
    
    /// All localized descriptions of the tag.
    public let localizationDescriptions: [String: String]
}
