//
//  ISO8601DateFormatter+Extensions.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

extension ISO8601DateFormatter {
    internal static let internetDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    internal static let internetDateWithFractionalSecondsFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
