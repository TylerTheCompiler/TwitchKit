//
//  LegacyCreateUserConnectionToViewerHeartbeatServiceRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Creates a connection between a user (an authenticated Twitch user, who must be associated with one of your
/// game-user accounts) and VHS, and starts returning the user's VHS data in each heartbeat. The game user is
/// specified by a required `identifier` parameter.
///
/// An HTTP 422 response is returned if the game (identified by a client ID) is not configured. An HTTP 409
/// response is returned if the game-user identifier is associated with a Twitch ID other than the authenticated
/// Twitch user.
public struct LegacyCreateUserConnectionToViewerHeartbeatServiceRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The identifier of a game user.
        public let identifier: String
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .put
    public let path = "/user/vhs"
    public let body: RequestBody?
    
    /// Creates a new Create User Connection To Viewer Heartbeat Service legacy request.
    ///
    /// - Parameter identifier: The identifier of a game user.
    public init(identifier: String) {
        body = .init(identifier: identifier)
    }
}
