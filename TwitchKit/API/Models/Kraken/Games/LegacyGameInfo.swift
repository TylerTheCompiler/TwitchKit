//
//  LegacyGameInfo.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyGameInfo: Decodable {
    
    /// <#Description#>
    public let channels: Int
    
    /// <#Description#>
    public let viewers: Int
    
    /// <#Description#>
    public let game: LegacyGame
}
