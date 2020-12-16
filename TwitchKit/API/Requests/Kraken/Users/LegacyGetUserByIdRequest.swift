//
//  LegacyGetUserByIdRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a specified user object.
public struct LegacyGetUserByIdRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyUser
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get User by Id legacy request.
    ///
    /// - Parameter userId: The user ID of the user to get.
    public init(userId: String) {
        path = "/users/\(userId)"
    }
}
