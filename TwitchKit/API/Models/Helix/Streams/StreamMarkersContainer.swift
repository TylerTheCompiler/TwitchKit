//
//  StreamMarkersContainer.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A container of stream markers.
public struct StreamMarkersContainer: Decodable {
    
    /// A video that contains stream markers.
    public struct Video: Decodable {
        
        /// ID of the stream (VOD/video) that was marked.
        public let videoId: String
        
        /// The video's stream markers.
        public let markers: [StreamMarker]
    }
    
    /// ID of the user whose markers are returned.
    public let userId: String
    
    /// Display name corresponding to `userId`.
    public let userName: String
    
    /// Login corresponding to `userId`.
    public let userLogin: String
    
    /// The videos containing stream markers.
    public let videos: [Video]
}
