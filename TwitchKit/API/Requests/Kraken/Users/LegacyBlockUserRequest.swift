//
//  LegacyBlockUserRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Blocks a user; that is, adds a specified target user to the blocks list of a specified source user.
public struct LegacyBlockUserRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The user that was blocked.
        public let user: LegacyUser
        
        /// The ID of the block.
        public let id: String
        
        /// The date the user was blocked.
        @InternetDate
        public private(set) var updatedAt: Date
        
        private enum CodingKeys: String, CodingKey {
            case id = "_id"
            case updatedAt
            case user
        }
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .put
    public let path: String
    
    /// Creates a new Block User legacy request.
    ///
    /// - Parameters:
    ///   - sourceUserId: The user ID of the user doing the blocking.
    ///   - targetUserId: The user ID of the user to be blocked.
    public init(sourceUserId: String, targetUserId: String) {
        path = "/users/\(sourceUserId)/blocks/\(targetUserId)"
    }
}
