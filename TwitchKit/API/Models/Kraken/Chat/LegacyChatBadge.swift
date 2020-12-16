//
//  LegacyChatBadge.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyChatBadge: Decodable {
    
    /// <#Description#>
    @SafeURL
    public private(set) var alpha: URL?
    
    /// <#Description#>
    @SafeURL
    public private(set) var image: URL?
    
    /// <#Description#>
    @SafeURL
    public private(set) var svg: URL?
}
