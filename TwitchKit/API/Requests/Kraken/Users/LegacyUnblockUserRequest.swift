//
//  LegacyUnblockUserRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Unblocks a user; that is, deletes a specified target user from the blocks list of a specified source user.
///
/// There is an error if the target user is not on the source user’s block list (404 Not Found) or the delete
/// failed (422 Unprocessable Entity).
public struct LegacyUnblockUserRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .delete
    public let path: String
    
    /// Creates a new Unblock User legacy request.
    ///
    /// - Parameters:
    ///   - sourceUserId: The user ID of the user doing the unblocking.
    ///   - targetUserId: The user ID of the user to unblock.
    public init(sourceUserId: String, targetUserId: String) {
        path = "/users/\(sourceUserId)/blocks/\(targetUserId)"
    }
}
