//
//  LegacyCurrentUser.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyCurrentUser: Decodable {
    
    /// <#Description#>
    public struct Notifications: Decodable {
        
        /// <#Description#>
        public let email: Bool
        
        /// <#Description#>
        public let push: Bool
    }
    
    /// <#Description#>
    public let id: Int
    
    /// <#Description#>
    public let bio: String?
    
    /// <#Description#>
    public let displayName: String
    
    /// <#Description#>
    public let email: String
    
    /// <#Description#>
    public let isEmailVerified: Bool
    
    /// <#Description#>
    @SafeURL
    public private(set) var logo: URL?
    
    /// <#Description#>
    public let name: String
    
    /// <#Description#>
    public let notifications: Notifications
    
    /// <#Description#>
    public let isPartnered: Bool
    
    /// <#Description#>
    public let isTwitterConnected: Bool
    
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
        case email
        case isEmailVerified = "emailVerified"
        case logo
        case name
        case notifications
        case isPartnered = "partnered"
        case isTwitterConnected = "twitterConnected"
        case type
        case createdAt
        case updatedAt
    }
}
