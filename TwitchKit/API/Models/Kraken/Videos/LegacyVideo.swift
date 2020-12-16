//
//  LegacyVideo.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyVideo: Decodable {
    
    /// <#Description#>
    public enum BroadcastType: String, Decodable {
        
        /// <#Description#>
        case archive
        
        /// <#Description#>
        case highlight
        
        /// <#Description#>
        case upload
    }
    
    /// <#Description#>
    public struct ChannelInfo: Decodable {
        
        /// <#Description#>
        public let id: String
        
        /// <#Description#>
        public let displayName: String
        
        /// <#Description#>
        public let name: String
        
        private enum CodingKeys: String, CodingKey {
            case id = "_id"
            case displayName
            case name
        }
    }
    
    /// <#Description#>
    public struct ThumbnailInfo: Decodable {
        
        /// <#Description#>
        public struct Thumbnail: Decodable {
            
            /// <#Description#>
            public let type: String
            
            /// <#Description#>
            @SafeURL
            public private(set) var url: URL?
        }
        
        /// <#Description#>
        public struct TemplateThumbnail: Decodable {
            
            /// <#Description#>
            public let type: String
            
            /// <#Description#>
            public let url: TemplateURL<ImageTemplateURLStrategy>
        }
        
        /// <#Description#>
        public let large: [Thumbnail]
        
        /// <#Description#>
        public let medium: [Thumbnail]
        
        /// <#Description#>
        public let small: [Thumbnail]
        
        /// <#Description#>
        public let template: [TemplateThumbnail]
    }
    
    /// <#Description#>
    public struct MutedSegment: Decodable {
        
        /// <#Description#>
        public let duration: Int
        
        /// <#Description#>
        public let offset: Int
    }
    
    /// <#Description#>
    public let id: String
    
    /// <#Description#>
    public let broadcastId: String
    
    /// <#Description#>
    public let broadcastType: BroadcastType
    
    /// <#Description#>
    public let channel: ChannelInfo
    
    /// <#Description#>
    public let description: String
    
    /// <#Description#>
    public let descriptionHtml: String
    
    /// <#Description#>
    public let fps: [String: Double]
    
    /// <#Description#>
    public let game: String
    
    /// <#Description#>
    public let language: String
    
    /// <#Description#>
    public let length: Int
    
    /// <#Description#>
    public let mutedSegments: [MutedSegment]
    
    /// <#Description#>
    public let preview: LegacyThumbnails
    
    /// <#Description#>
    public let resolutions: [String: String]
    
    /// <#Description#>
    public let status: String
    
    /// <#Description#>
    public let tagList: String
    
    /// <#Description#>
    public let thumbnails: ThumbnailInfo
    
    /// <#Description#>
    public let title: String
    
    /// <#Description#>
    @SafeURL
    public private(set) var url: URL?
    
    /// <#Description#>
    public let viewable: String
    
    /// <#Description#>
    public let views: Int
    
    /// <#Description#>
    @InternetDate
    public private(set) var createdAt: Date
    
    /// <#Description#>
    @InternetDate
    public private(set) var publishedAt: Date
    
    /// <#Description#>
    @OptionalInternetDateWithOptionalFractionalSeconds
    public private(set) var viewableAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case broadcastId
        case broadcastType
        case channel
        case description
        case descriptionHtml
        case fps
        case game
        case language
        case length
        case mutedSegments
        case preview
        case resolutions
        case status
        case tagList
        case thumbnails
        case title
        case url
        case viewable
        case views
        case createdAt
        case publishedAt
        case viewableAt
    }
}
