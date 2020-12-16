//
//  TemplateURLStrategy.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A type that contains an array of token strings to be replaced in order to create a valid URL.
public protocol TemplateURLStrategy {
    
    /// An array of token strings.
    static var templateStrings: [String] { get }
}

extension TemplateURLStrategy {
    internal static func urlByReplacingTemplateStrings(in urlString: String,
                                                       with replacementStrings: [String]) -> URL? {
        var urlString = urlString
        for (templateString, replacementString) in zip(templateStrings, replacementStrings) {
            urlString = urlString.replacingOccurrences(of: "{\(templateString)}", with: replacementString)
        }
        
        return URL(string: urlString)
    }
}
