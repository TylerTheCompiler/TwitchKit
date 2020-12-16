//
//  Game.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Structure containing basic information for a video game.
public struct Game: Decodable {
    
    /// Game ID.
    public let id: String
    
    /// Game name.
    public let name: String
    
    /// Template URL for a game's box art.
    public let boxArtUrl: TemplateURL<ImageTemplateURLStrategy>
}
