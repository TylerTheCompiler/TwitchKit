//
//  LegacyGetClipRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets details about a specified clip.
///
/// Clips are referenced by a globally unique string called a slug.
///
/// - Note: The clips service returns a maximum of 1000 clips,
public struct LegacyGetClipRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyClip
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get Clip legacy request.
    ///
    /// - Parameter clipSlug: The slug of the clip to get.
    public init(clipSlug: String) {
        path = "/clips/\(clipSlug)"
    }
}
