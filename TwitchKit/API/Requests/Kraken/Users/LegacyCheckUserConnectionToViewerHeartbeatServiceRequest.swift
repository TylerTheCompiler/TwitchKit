//
//  LegacyCheckUserConnectionToViewerHeartbeatServiceRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Checks whether an authenticated Twitch user is connected to VHS.
///
/// If a connection to the service exists for the specified user, the linked game user's ID is returned;
/// otherwise, an HTTP 404 response is returned.
public struct LegacyCheckUserConnectionToViewerHeartbeatServiceRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The game user's identifier.
        public let identifier: String
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/user/vhs"
    
    /// Creates a new Check User Connection To Viewer Heartbeat Service legacy request.
    public init() {}
}
