//
//  Emote.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/26/21.
//

/// A Twitch emote.
public struct Emote: Decodable {
    
    /// The type of emote.
    public enum EmoteType: String, Decodable {
        
        /// Indicates a custom Bits tier emote.
        case bitsTier = "bitstier"
        
        /// Indicates a custom follower emote.
        case follower
        
        /// Indicates a custom subscriber emote.
        case subscriptions
    }
    
    /// Represents a format that an emote can be available in (animated or static).
    public enum Format: String, Decodable {
        
        /// Indicates an animated GIF is available for this emote.
        case animated
        
        /// Returns an animated GIF if available, otherwise, returns the static PNG.
        case `default`
        
        /// Indicates a static PNG file is available for this emote.
        case `static`
        
        /// Creates a new instance.
        ///
        /// If the string does not represent one of the predefined formats, then the format created is `.default`.
        ///
        /// - Parameter rawValue: The raw value to use for the new instance.
        public init(rawValue: String) {
            switch rawValue {
            case "animated": self = .animated
            case "default": self = .`default`
            case "static": self = .static
            default: self = .`default`
            }
        }
    }
    
    /// Represents a scale that an emote can be available in.
    public enum Scale: String, Decodable {
        case small = "1.0"
        case medium = "2.0"
        case large = "3.0"
        
        /// Creates a new instance.
        ///
        /// If the string does not represent one of the predefined scales, then the scale created is `.small`.
        ///
        /// - Parameter rawValue: The raw value to use for the new instance.
        public init(rawValue: String) {
            switch rawValue {
            case "1.0": self = .small
            case "2.0": self = .small
            case "3.0": self = .small
            default: self = .small
            }
        }
        
        internal init(imageURLKey: String) {
            switch imageURLKey {
            case "url_1x": self = .small
            case "url_2x": self = .medium
            case "url_4x": self = .large
            default: self = .small
            }
        }
    }
    
    /// Represents a background theme that an emote can be available in.
    public enum ThemeMode: String, Decodable {
        case light
        case dark
        
        public init(rawValue: String) {
            switch rawValue {
            case "light": self = .light
            case "dark": self = .dark
            default: self = .light
            }
        }
    }
    
    /// An ID that identifies the emote.
    public let identifier: String
    
    /// The name of the emote. This is the name that viewers type in the chat window to get the emote to appear.
    public let name: String
    
    /// Contains the image URLs for the emote. These image URLs will always provide a static (i.e., non-animated)
    /// emote image with a light background.
    ///
    /// - NOTE: The preference is for you to use the templated URL in the template field (which is not included
    ///         in this type) to fetch the image instead of using these URLs.
    public let imageURLs: [Scale: URL]
    
    /// The subscriber tier at which the emote is unlocked.
    ///
    /// This field contains the tier information only if `emoteType` is set to `.subscriptions`.
    /// Otherwise, it's an empty string.
    public let tier: String?
    
    /// The type of emote.
    public let emoteType: EmoteType?
    
    /// An ID that identifies the emote set that the emote belongs to.
    public let emoteSetId: String?
    
    /// The ID of the broadcaster who owns the emote, if any.
    public let ownerId: String?
    
    /// The formats that the emote is available in.
    public let formats: [Format]
    
    /// The sizes that the emote is available in.
    public let scales: [Scale]
    
    /// The background themes that the emote is available in.
    public let themeModes: [ThemeMode]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageURLs = try container.decode([String: URL].self, forKey: .images)
            .reduce(into: [:]) { $0[Scale(imageURLKey: $1.key)] = $1.value }
        tier = try container.decodeIfPresent(String.self, forKey: .tier)
        emoteType = try container.decodeIfPresent(EmoteType.self, forKey: .emoteType)
        emoteSetId = try container.decodeIfPresent(String.self, forKey: .emoteSetId)
        ownerId = try container.decodeIfPresent(String.self, forKey: .ownerId)
        formats = try container.decode([Format].self, forKey: .format)
        scales = try container.decode([Scale].self, forKey: .scale)
        themeModes = try container.decode([ThemeMode].self, forKey: .themeMode)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case images
        case tier
        case emoteType
        case emoteSetId
        case ownerId
        case format
        case scale
        case themeMode
    }
}
