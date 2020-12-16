//
//  LegacyCollectionItem.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyCollectionItem: Decodable {
    
    /// <#Description#>
    public let id: String
    
    /// <#Description#>
    public let descriptionHtml: String
    
    /// <#Description#>
    public let duration: Int
    
    /// <#Description#>
    public let game: String
    
    /// <#Description#>
    public let itemId: String
    
    /// <#Description#>
    public let itemType: String
    
    /// <#Description#>
    public let owner: LegacyUser
    
    /// <#Description#>
    public let thumbnails: LegacyThumbnails
    
    /// <#Description#>
    public let title: String
    
    /// <#Description#>
    public let views: Int
    
    /// <#Description#>
    @InternetDate
    public private(set) var publishedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case descriptionHtml
        case duration
        case game
        case itemId
        case itemType
        case owner
        case thumbnails
        case title
        case views
        case publishedAt
    }
}
