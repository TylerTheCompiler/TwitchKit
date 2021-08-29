//
//  UnblockUserRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/28/21.
//

/// Unblocks the specified user on behalf of the authenticated user.
public struct UnblockUserRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public enum QueryParamKey: String {
        case targetUserId = "target_user_id"
    }
    
    public let method: HTTPMethod = .delete
    public let path = "/users/blocks"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Unblock User request.
    ///
    /// - Parameters:
    ///   - targetUserId: User ID of the user to be unblocked.
    public init(targetUserId: String) {
        queryParams = [(.targetUserId, targetUserId)]
    }
}
