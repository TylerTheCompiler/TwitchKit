//
//  LegacyCollection.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyCollection: Decodable {
    
    /// <#Description#>
    public let id: String
    
    /// <#Description#>
    public let itemsCount: Int
    
    /// <#Description#>
    public let owner: LegacyUser
    
    /// <#Description#>
    public let thumbnails: LegacyThumbnails?
    
    /// <#Description#>
    public let title: String
    
    /// <#Description#>
    public let totalDuration: Int
    
    /// <#Description#>
    public let views: Int
    
    /// <#Description#>
    @InternetDateWithFractionalSeconds
    public private(set) var createdAt: Date
    
    /// <#Description#>
    @InternetDateWithFractionalSeconds
    public private(set) var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case itemsCount
        case owner
        case thumbnails
        case title
        case totalDuration
        case views
        case createdAt
        case updatedAt
    }
}
