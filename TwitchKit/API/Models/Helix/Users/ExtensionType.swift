//
//  ExtensionType.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// The type of a Twitch Extension.
public enum ExtensionType: String, Decodable, CodingKey, CaseIterable {
    case component
    case panel
    case overlay
    case mobile
}
