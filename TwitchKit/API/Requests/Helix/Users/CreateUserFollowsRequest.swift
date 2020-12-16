//
//  CreateUserFollowsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Adds a specified user to the followers of a specified channel.
public struct CreateUserFollowsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// User ID of the follower
        public let fromId: String
        
        /// ID of the channel to be followed by the user
        public let toId: String
        
        /// If true, the user gets email or push notifications (depending on the user’s notification settings)
        /// when the channel goes live. Default value is false.
        public let allowNotifications: Bool?
    }
    
    public let method: HTTPMethod = .post
    public let path = "/users/follows"
    public let body: RequestBody?
    
    /// Creates a new Create User Follows request.
    ///
    /// - Parameters:
    ///   - fromId: User ID of the follower.
    ///   - toId: ID of the channel to be followed by the user.
    ///   - allowNotifications: If true, the user gets email or push notifications (depending on the user’s
    ///                         notification settings) when the channel goes live. Default value is false.
    public init(fromId: String,
                toId: String,
                allowNotifications: Bool? = nil) {
        body = .init(fromId: fromId,
                     toId: toId,
                     allowNotifications: allowNotifications)
    }
}
