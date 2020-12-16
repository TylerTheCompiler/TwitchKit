//
//  CreatedClip.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A URL and ID of a created clip.
public struct CreatedClip: Decodable {
    
    /// ID of the clip that was created.
    public let id: String
    
    /// URL of the edit page for the clip.
    @SafeURL
    public private(set) var editUrl: URL?
}
