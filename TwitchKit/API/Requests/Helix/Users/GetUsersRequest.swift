//
//  GetUsersRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Gets information about one or more specified Twitch users.
///
/// Users are identified by optional user IDs and/or login name. If neither a user ID nor a login
/// name is specified, the user is looked up by Bearer token.
public struct GetUsersRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The returned list of users.
        public let users: [User]
        
        private enum CodingKeys: String, CodingKey {
            case users = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case id
        case login
    }
    
    public let path = "/users"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Users request.
    ///
    /// - Note: The limit of 100 IDs and login names is the total limit. You can request, for example, 50 of each or
    ///         100 of one of them. You cannot request 100 of both.
    ///
    /// - Parameters:
    ///   - userIds: User ID. Multiple user IDs can be specified. Limit: 100.
    ///   - logins: User login name. Multiple login names can be specified. Limit: 100.
    public init(userIds: [String] = [], logins: [String] = []) {
        queryParams = userIds.map {
            (.id, $0)
        } + logins.map {
            (.login, $0)
        }
    }
}
