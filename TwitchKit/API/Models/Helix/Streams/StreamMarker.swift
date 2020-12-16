//
//  StreamMarker.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// An arbitrary point in a stream that the broadcaster wants to mark.
public struct StreamMarker: Decodable {
    
    /// Unique ID of the marker.
    public let id: String
    
    /// Description of the marker.
    public let description: String
    
    /// Relative offset (in seconds) of the marker, from the beginning of the stream.
    public let positionSeconds: Int
    
    /// A link to the stream with a query parameter that is a timestamp of the marker's location.
    @SafeURL
    public private(set) var url: URL?
    
    /// RFC3339 timestamp of the marker.
    @InternetDate
    public private(set) var createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case positionSeconds
        case url
        case createdAt
    }
}
