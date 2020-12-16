//
//  LegacyDeleteUserConnectionToViewerHeartbeatServiceRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Deletes the connection between an authenticated Twitch user and VHS.
public struct LegacyDeleteUserConnectionToViewerHeartbeatServiceRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .delete
    public let path = "/user/vhs"
    
    /// Creates a new Delete User Connection To Viewer Heartbeat Service legacy request.
    public init() {}
}
