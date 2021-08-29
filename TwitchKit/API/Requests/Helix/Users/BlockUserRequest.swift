//
//  BlockUserRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/28/21.
//

/// Blocks the specified user on behalf of the authenticated user.
public struct BlockUserRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    /// Source context for blocking a user.
    public enum SourceContext: String {
        case chat
        case whisper
    }
    
    /// Reason for blocking a user.
    public enum Reason: String {
        case spam
        case harassment
        case other
    }
    
    public enum QueryParamKey: String {
        case targetUserId = "target_user_id"
        case sourceContext = "source_context"
        case reason
    }
    
    public let method: HTTPMethod = .put
    public let path = "/users/blocks"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Block User request.
    ///
    /// - Parameters:
    ///   - targetUserId: User ID of the user to be blocked.
    ///   - sourceContext: Source context for blocking the user.
    ///   - reason: Reason for blocking the user.
    public init(targetUserId: String,
                sourceContext: SourceContext? = nil,
                reason: Reason? = nil) {
        queryParams = [
            (.targetUserId, targetUserId),
            (.sourceContext, sourceContext?.rawValue),
            (.reason, reason?.rawValue)
        ]
    }
}
