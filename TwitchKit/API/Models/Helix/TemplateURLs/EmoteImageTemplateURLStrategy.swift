//
//  EmoteImageTemplateURLStrategy.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/26/21.
//

/// A template URL strategy where the URL contains the strings `{{id}}`, `{{format}}`, `{{theme_mode}}`, and `{{scale}}`
/// which are to be replaced by emote-related values to create a URL pointing to a specific emote image.
public enum EmoteImageTemplateURLStrategy: TemplateURLStrategy {
    public static let templateStrings = ["{id}", "{format}", "{theme_mode}", "{scale}"]
}

extension TemplateURL where Strategy == EmoteImageTemplateURLStrategy {
    
    /// Returns a URL created from the template string with the `{{id}}`, `{{format}}`, `{{theme_mode}}`, and `{{scale}}`
    /// tokens replaced with the given
    ///
    /// - Parameters:
    ///   - width: The width of the desired image.
    ///   - height: The height of the desired image.
    /// - Returns: A URL pointing to an image that is of the desired width and height.
    ///
    
    public func with(
        emoteId: String,
        format: Emote.Format = .default,
        themeMode: Emote.ThemeMode = .light,
        scale: Emote.Scale = .small
    ) -> URL? {
        Strategy.urlByReplacingTemplateStrings(in: template, with: [
            emoteId.description,
            format.rawValue,
            themeMode.rawValue,
            scale.rawValue
        ])
    }
}
