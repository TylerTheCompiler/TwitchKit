//
//  Commercial.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A commercial/ad started on a live stream.
public struct Commercial: Decodable {
    
    /// Length of a commercial in seconds.
    public enum Length: Int, Codable {
        case thirtySeconds = 30
        case oneMinute = 60
        case oneMinuteThirtySeconds = 90
        case twoMinutes = 120
        case twoMinutesThirtySeconds = 150
        case threeMinutes = 180
    }
    
    /// Length of the triggered commercial.
    public let length: Length
    
    /// Provides contextual information on why the request failed.
    public let message: String
    
    /// Seconds until the next commercial can be served on this channel.
    public let retryAfter: Int
}
