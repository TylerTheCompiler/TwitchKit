//
//  LegacyTeam.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyTeam: Decodable {
    
    /// <#Description#>
    public let id: Int
    
    /// <#Description#>
    public let background: String?
    
    /// <#Description#>
    @SafeURL
    public private(set) var banner: URL?
    
    /// <#Description#>
    public let displayName: String
    
    /// <#Description#>
    public let info: String
    
    /// <#Description#>
    @SafeURL
    public private(set) var logo: URL?
    
    /// <#Description#>
    public let name: String?
    
    /// <#Description#>
    public let users: [LegacyChannel]?
    
    /// <#Description#>
    @InternetDate
    public private(set) var createdAt: Date
    
    /// <#Description#>
    @InternetDate
    public private(set) var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case background
        case banner
        case displayName
        case info
        case logo
        case name
        case users
        case createdAt
        case updatedAt
    }
}
