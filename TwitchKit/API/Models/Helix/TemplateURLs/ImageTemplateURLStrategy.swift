//
//  ImageTemplateURLStrategy.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A template URL strategy where the URL contains the strings `{width}` and `{height}` which are to be replaced
/// by integers to create a URL pointing to an image of the given size.
public enum ImageTemplateURLStrategy: TemplateURLStrategy {
    public static let templateStrings = ["width", "height"]
}

extension TemplateURL where Strategy == ImageTemplateURLStrategy {
    
    /// Returns a URL created from the template string with the `{width}` and `{height}` tokens replaced with the
    /// given integer values.
    ///
    /// - Parameters:
    ///   - width: The width of the desired image.
    ///   - height: The height of the desired image.
    /// - Returns: A URL pointing to an image that is of the desired width and height.
    public func with(width: Int, height: Int) -> URL? {
        Strategy.urlByReplacingTemplateStrings(in: template, with: [width.description, height.description])
    }
}
