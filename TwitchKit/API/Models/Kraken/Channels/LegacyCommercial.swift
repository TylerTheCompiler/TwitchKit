//
//  LegacyCommercial.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyCommercial: Decodable {
    
    /// <#Description#>
    public enum Length: Int, Codable {
        case thirtySeconds = 30
        case oneMinute = 60
        case oneAndAHalfMinutes = 90
        case twoMinutes = 120
        case twoAndAHalfMinutes = 150
        case threeMinutes = 180
    }
    
    /// <#Description#>
    public let length: Length
    
    /// <#Description#>
    public let message: String
    
    /// <#Description#>
    public let retryAfter: Int
    
    private enum CodingKeys: String, CodingKey {
        case length = "Length"
        case message = "Message"
        case retryAfter = "RetryAfter"
    }
}
