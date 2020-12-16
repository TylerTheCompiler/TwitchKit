//
//  ChatDuration.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

/// A duration used for various chat commands.
public struct ChatDuration {
    
    /// The number of seconds.
    public let seconds: Int
    
    /// The number of minutes.
    public let minutes: Int
    
    /// The number of hours.
    public let hours: Int
    
    /// The number of days.
    public let days: Int
    
    /// The number of weeks.
    public let weeks: Int
    
    /// Creates a `ChatDuration` with the given number of different units of time.
    ///
    /// - Parameters:
    ///   - seconds: The number of seconds to add to the duration.
    ///   - minutes: The number of minutes to add to the duration.
    ///   - hours: The number of hours to add to the duration.
    ///   - days: The number of days to add to the duration.
    ///   - weeks: The number of weeks to add to the duration.
    public init(seconds: Int = 0,
                minutes: Int = 0,
                hours: Int = 0,
                days: Int = 0,
                weeks: Int = 0) {
        self.seconds = seconds
        self.minutes = minutes
        self.hours = hours
        self.days = days
        self.weeks = weeks
    }
    
    internal var rawValue: String {
        var components = [String]()
        if weeks > 0 { components.append("\(weeks)w") }
        if days > 0 { components.append("\(days)d") }
        if hours > 0 { components.append("\(hours)h") }
        if minutes > 0 { components.append("\(minutes)m") }
        if seconds > 0 { components.append("\(seconds)s") }
        return components.joined()
    }
}
