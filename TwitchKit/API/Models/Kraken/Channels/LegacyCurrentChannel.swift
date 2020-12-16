//
//  LegacyCurrentChannel.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyCurrentChannel: Decodable {
    
    /// <#Description#>
    public let id: String
    
    /// <#Description#>
    public let isMature: Bool
    
    /// <#Description#>
    public let status: String
    
    /// <#Description#>
    public let broadcasterLanguage: String
    
    /// <#Description#>
    public let displayName: String
    
    /// <#Description#>
    public let game: String
    
    /// <#Description#>
    public let language: String
    
    /// <#Description#>
    public let name: String
    
    /// <#Description#>
    public let isPartner: Bool
    
    /// <#Description#>
    @SafeURL
    public private(set) var logo: URL?
    
    /// <#Description#>
    @SafeURL
    public private(set) var videoBanner: URL?
    
    /// <#Description#>
    @SafeURL
    public private(set) var profileBanner: URL?
    
    /// <#Description#>
    public let profileBannerBackgroundColor: String?
    
    /// <#Description#>
    @SafeURL
    public private(set) var url: URL?
    
    /// <#Description#>
    public let views: Int
    
    /// <#Description#>
    public let followers: Int
    
    /// <#Description#>
    public let broadcasterType: String
    
    /// <#Description#>
    public let streamKey: String?
    
    /// <#Description#>
    public let email: String?
    
    /// <#Description#>
    @InternetDate
    public private(set) var createdAt: Date
    
    /// <#Description#>
    @InternetDate
    public private(set) var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case isMature = "mature"
        case status
        case broadcasterLanguage
        case displayName
        case game
        case language
        case name
        case isPartner = "partner"
        case logo
        case videoBanner
        case profileBanner
        case profileBannerBackgroundColor
        case url
        case views
        case followers
        case broadcasterType
        case streamKey
        case email
        case createdAt
        case updatedAt
    }
}
