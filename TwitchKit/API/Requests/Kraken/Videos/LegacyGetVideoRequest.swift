//
//  LegacyGetVideoRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a specified video object.
public struct LegacyGetVideoRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyVideo
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get Video legacy request.
    ///
    /// - Parameter videoId: The video ID of the video to get.
    public init(videoId: String) {
        path = "/videos/\(videoId)"
    }
}
