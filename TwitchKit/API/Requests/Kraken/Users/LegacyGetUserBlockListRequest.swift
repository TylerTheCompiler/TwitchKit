//
//  LegacyGetUserBlockListRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a specified user's block list. List sorted by recency, newest first.
public struct LegacyGetUserBlockListRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// A container of a blocked user.
        public struct UserBlock: Decodable {
            
            /// The blocked user.
            public let user: LegacyUser
        }
        
        /// The returned list of blocked users.
        public let blocks: [UserBlock]
        
        /// The total number of returned blocked users.
        public let total: Int?
        
        private enum CodingKeys: String, CodingKey {
            case blocks
            case total = "_total"
        }
    }
    
    public enum QueryParamKey: String {
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get User Block List legacy request.
    ///
    /// - Parameters:
    ///   - userId: The user ID of the user whose block list to get.
    ///   - limit: Maximum number of objects in array. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination. Default: 0.
    public init(userId: String, limit: Int? = nil, offset: Int? = nil) {
        path = "/users/\(userId)/blocks"
        queryParams = [
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
