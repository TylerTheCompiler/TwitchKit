//
//  LegacyClip.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyClip: Decodable {
    
    /// <#Description#>
    public struct User: Decodable {
        
        /// <#Description#>
        public let id: String
        
        /// <#Description#>
        public let name: String
        
        /// <#Description#>
        public let displayName: String
        
        /// <#Description#>
        @SafeURL
        public private(set) var channelUrl: URL?
        
        /// <#Description#>
        @SafeURL
        public private(set) var logo: URL?
    }
    
    /// <#Description#>
    public struct VOD: Decodable {
        
        /// <#Description#>
        public let id: String
        
        /// <#Description#>
        @SafeURL
        public private(set) var url: URL?
    }
    
    /// <#Description#>
    public struct Thumbnails: Decodable {
        
        /// <#Description#>
        @SafeURL
        public private(set) var medium: URL?
        
        /// <#Description#>
        @SafeURL
        public private(set) var small: URL?
        
        /// <#Description#>
        @SafeURL
        public private(set) var tiny: URL?
    }
    
    /// <#Description#>
    public let slug: String
    
    /// <#Description#>
    public let trackingId: String
    
    /// <#Description#>
    @SafeURL
    public private(set) var url: URL?
    
    /// <#Description#>
    @SafeURL
    public private(set) var embedUrl: URL?
    
    /// <#Description#>
    public let embedHtml: String
    
    /// <#Description#>
    public let broadcaster: User
    
    /// <#Description#>
    public let curator: User
    
    /// <#Description#>
    public let vod: VOD
    
    /// <#Description#>
    public let game: String
    
    /// <#Description#>
    public let language: String
    
    /// <#Description#>
    public let title: String
    
    /// <#Description#>
    public let views: Int
    
    /// <#Description#>
    public let duration: Double
    
    /// <#Description#>
    public let thumbnails: Thumbnails
    
    /// <#Description#>
    @InternetDate
    public private(set) var createdAt: Date
}
