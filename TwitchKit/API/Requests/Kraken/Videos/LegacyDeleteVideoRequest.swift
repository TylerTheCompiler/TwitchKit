//
//  LegacyDeleteVideoRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Deletes a specified video.
///
/// The video can be any type of VOD (Video on Demand): past broadcasts (videos created from a live Twitch stream),
/// highlights (cut from past broadcasts), or uploads (manually uploaded by broadcasters).
public struct LegacyDeleteVideoRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .delete
    public let path: String
    
    /// Creates a new Delete Video legacy request.
    ///
    /// - Parameter videoId: The video ID of the video to delete.
    public init(videoId: String) {
        path = "/videos/\(videoId)"
    }
}
