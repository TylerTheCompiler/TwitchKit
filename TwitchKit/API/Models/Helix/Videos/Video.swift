//
//  Video.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A Twitch VOD.
public struct Video: Decodable {
    
    /// The type of video.
    public enum VideoType: String, Decodable {
        
        /// The video was uploaded to Twitch.
        case upload
        
        /// The video is an archive of a live stream.
        case archive
        
        /// The video is a highlight of a live stream.
        case highlight
    }
    
    /// Indicates whether the video is publicly viewable.
    public enum Viewability: String, Decodable {
        
        /// The video is publicly viewable.
        case `public`
        
        /// The video is not publicly viewable.
        case `private`
    }
    
    /// A portion of a Twitch video (VOD).
    public struct Segment: Decodable {
        
        /// Duration of the muted segment in seconds.
        public let duration: Int
        
        /// Offset in the video (in seconds) at which the muted segment begins.
        public let offset: Int
    }
    
    /// ID of the video.
    public let id: String
    
    /// ID of the stream that the video originated from if `type` is `.archive`. Otherwise nil.
    public let streamId: String?
    
    /// ID of the user who owns the video.
    public let userId: String
    
    /// Login of the user who owns the video.
    public let userLogin: String
    
    /// Display name corresponding to `userId`.
    public let userName: String
    
    /// Title of the video.
    public let title: String
    
    /// Description of the video.
    public let description: String
    
    /// Date when the video was created.
    @InternetDate
    public private(set) var createdAt: Date
    
    /// Date when the video was published.
    @InternetDate
    public private(set) var publishedAt: Date
    
    /// URL of the video.
    @SafeURL
    public private(set) var url: URL?
    
    /// Template URL for the thumbnail of the video.
    public let thumbnailUrl: TemplateURL<ImageTemplateURLStrategy>
    
    /// Indicates whether the video is publicly viewable.
    public let viewable: Viewability
    
    /// Number of times the video has been viewed.
    public let viewCount: Int
    
    /// Language of the video.
    public let language: String
    
    /// Type of video.
    public let type: VideoType
    
    /// Length of the video.
    public let duration: String
    
    /// Array of muted segments in the video. If there are no muted segments, the value will be null.
    @EmptyIfNull
    public private(set) var mutedSegments: [Segment]
}
