//
//  LegacyEmoteDetail.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyEmoteDetail: Decodable {
    
    /// <#Description#>
    public struct Image: Decodable {
        
        /// <#Description#>
        public let emoticonSet: Int
        
        /// <#Description#>
        public let height: Int
        
        /// <#Description#>
        public let width: Int
        
        /// <#Description#>
        @SafeURL
        public private(set) var url: URL?
    }
    
    /// <#Description#>
    public let id: Int
    
    /// <#Description#>
    public let regex: String
    
    /// <#Description#>
    public let images: Image
}
