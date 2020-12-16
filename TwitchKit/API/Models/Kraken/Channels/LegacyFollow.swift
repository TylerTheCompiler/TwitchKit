//
//  LegacyFollow.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyFollow: Decodable {
    
    /// <#Description#>
    @InternetDateWithFractionalSeconds
    public private(set) var createdAt: Date
    
    /// <#Description#>
    public let notifications: Bool
    
    /// <#Description#>
    public let user: LegacyUser?
    
    /// <#Description#>
    public let channel: LegacyChannel?
}
