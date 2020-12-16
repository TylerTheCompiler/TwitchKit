//
//  LegacyChannelSubscription.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyChannelSubscription: Decodable {
    
    /// <#Description#>
    public let id: String
    
    /// <#Description#>
    @InternetDate
    public private(set) var createdAt: Date
    
    /// <#Description#>
    public let subPlan: String
    
    /// <#Description#>
    public let subPlanName: String
    
    /// <#Description#>
    public let user: LegacyUser?
}
