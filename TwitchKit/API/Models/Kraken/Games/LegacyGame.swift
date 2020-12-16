//
//  LegacyGame.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyGame: Decodable {
    
    /// <#Description#>
    public let id: Int
    
    /// <#Description#>
    public let box: LegacyThumbnails
    
    /// <#Description#>
    public let giantbombId: Int
    
    /// <#Description#>
    public let logo: LegacyThumbnails
    
    /// <#Description#>
    public let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case box
        case giantbombId
        case logo
        case name
    }
}
