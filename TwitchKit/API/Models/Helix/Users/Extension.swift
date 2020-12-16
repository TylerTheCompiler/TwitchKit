//
//  TwitchExtension.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A Twitch Extension for a user.
public struct TwitchExtension: Decodable {
    
    /// ID of the extension.
    public let id: String
    
    /// Version of the extension.
    public let version: String
    
    /// Name of the extension.
    public let name: String
    
    /// Indicates whether the extension is configured such that it can be activated.
    public let canActivate: Bool
    
    /// Types for which the extension can be activated.
    public let validTypes: [ExtensionType]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case version
        case name
        case canActivate
        case validTypes = "type"
    }
}
