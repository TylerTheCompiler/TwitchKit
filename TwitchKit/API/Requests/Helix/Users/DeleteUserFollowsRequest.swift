//
//  DeleteUserFollowsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Deletes a specified user from the followers of a specified channel.
public struct DeleteUserFollowsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public enum QueryParamKey: String {
        case fromId = "from_id"
        case toId = "to_id"
    }
    
    public let method: HTTPMethod = .delete
    public let path = "/users/follows"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Delete User Follows request.
    ///
    /// - Parameters:
    ///   - fromId: User ID of the follower.
    ///   - toId: Channel to be unfollowed by the user.
    public init(fromId: String, toId: String) {
        queryParams = [
            (.fromId, fromId),
            (.toId, toId)
        ]
    }
}
