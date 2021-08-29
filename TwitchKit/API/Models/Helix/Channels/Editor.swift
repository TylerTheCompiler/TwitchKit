//
//  Editor.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/28/21.
//

/// A user who has been given editor permissions to a particular channel.
public struct Editor: Decodable {
    
    /// User ID of the editor.
    public let userId: String
    
    /// Display name of the editor.
    public let userName: String
    
    /// Date and time the editor was given editor permissions.
    @InternetDateWithFractionalSeconds
    public private(set) var createdAt: Date
}
