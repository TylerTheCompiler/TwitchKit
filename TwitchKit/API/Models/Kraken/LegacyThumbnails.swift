//
//  LegacyThumbnails.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyThumbnails: Decodable {
    
    /// <#Description#>
    @SafeURL
    public private(set) var large: URL?
    
    /// <#Description#>
    @SafeURL
    public private(set) var medium: URL?
    
    /// <#Description#>
    @SafeURL
    public private(set) var small: URL?
    
    /// <#Description#>
    public let template: TemplateURL<ImageTemplateURLStrategy>
}
