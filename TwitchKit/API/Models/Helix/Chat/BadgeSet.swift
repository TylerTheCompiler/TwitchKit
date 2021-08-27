//
//  BadgeSet.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/26/21.
//

/// A Twitch chat badge set.
public struct BadgeSet: Decodable {
    
    /// A Twitch chat badge.
    public struct Badge: Decodable {
        
        /// ID of the chat badge version.
        public let identifier: String
        
        /// Small image URL.
        public let imageURL1x: URL
        
        /// Medium image URL.
        public let imageURL2x: URL
        
        /// Large image URL.
        public let imageURL4x: URL
        
        private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case imageURL1x = "imageUrl1X"
            case imageURL2x = "imageUrl2X"
            case imageURL4x = "imageUrl4X"
        }
    }
    
    /// ID for the chat badge set.
    public let setId: String
    
    /// Contains chat badge objects for the set.
    public let badges: [Badge]
    
    private enum CodingKeys: String, CodingKey {
        case setId
        case badges = "versions"
    }
}
