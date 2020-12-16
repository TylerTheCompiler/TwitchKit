//
//  ChatEmote.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

/// A Twitch chat emote.
public struct ChatEmote: Hashable {
    
    /// A size of a Twitch chat emote.
    public enum Size: String {
        
        /// 1.0 size
        case small = "1.0"
        
        /// 2.0 size
        case medium = "2.0"
        
        /// 3.0 size
        case large = "3.0"
        
        /// 4.0 size
        case extraLarge = "4.0"
        
        /// Creates a `Size` closest to the given value.
        ///
        /// Depending on the value, the created `Size` is:
        /// - `value < 1.5`: `.small`
        /// - `1.5 <= value < 2.5`: `.medium`
        /// - `2.5 <= value < 3.5`: `.large`
        /// - `3.5 <= value`: `.extraLarge`
        ///
        /// - Parameter value: A value to create a `Size` from.
        public init<F>(roundingFrom value: F) where F: BinaryFloatingPoint {
            switch Float(value) {
            case ..<1.5: self = .small
            case 1.5..<2.5: self = .medium
            case 2.5..<3.5: self = .large
            case 3.5...: self = .extraLarge
            default: self = .medium
            }
        }
    }
    
    /// The ID of the emote.
    public let identifier: String
    
    /// Creats an emote with the given ID.
    ///
    /// - Parameter identifier: The ID of the emote.
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    /// Returns a URL for the emote's image for the given size.
    ///
    /// - Parameter size: The size of the emote for which to return an image URL.
    /// - Returns: A URL for an image of the emote with the given size.
    public func imageURL(for size: Size) -> URL? {
        URL(string: "https://static-cdn.jtvnw.net/emoticons/v1/\(identifier)/\(size.rawValue)")
    }
}
