//
//  LegacyGetCurrentUserRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a user object based on the access token provided.
///
/// Get Current User returns more data than Get User by ID, because Get Current User is privileged.
public struct LegacyGetCurrentUserRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyCurrentUser
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/user"
    
    /// Creates a new Get Current User request.
    public init() {}
}
