//
//  TemplateURL.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// A generic wrapper of a string representing a URL that contains tokens that can be replaced to create
/// variations of the URL.
public struct TemplateURL<Strategy>: Decodable where Strategy: TemplateURLStrategy {
    
    /// The URL template string containing the tokens to be replaced.
    public let template: String
    
    /// Creates a new `TemplateURL`.
    ///
    /// - Parameter template: The template string to use.
    public init(template: String) {
        self.template = template
    }
    
    public init(from decoder: Decoder) throws {
        template = try decoder.singleValueContainer().decode(String.self)
    }
}
