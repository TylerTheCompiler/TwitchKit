//
//  LegacyUser.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyUser: Decodable {
    
    /// <#Description#>
    public let id: Int
    
    /// <#Description#>
    public let bio: String?
    
    /// <#Description#>
    public let displayName: String
    
    /// <#Description#>
    @SafeURL
    public private(set) var logo: URL?
    
    /// <#Description#>
    public let name: String
    
    /// <#Description#>
    public let type: String
    
    /// <#Description#>
    @InternetDate
    public private(set) var createdAt: Date
    
    /// <#Description#>
    @InternetDate
    public private(set) var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case bio
        case displayName
        case logo
        case name
        case type
        case createdAt
        case updatedAt
    }
}
