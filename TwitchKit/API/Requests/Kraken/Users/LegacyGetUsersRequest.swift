//
//  LegacyGetUsersRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets the user objects for the specified Twitch login names (up to 100).
///
/// If a specified user's Twitch-registered email address is not verified, null is returned for that user.
public struct LegacyGetUsersRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of users.
        public let users: [LegacyUser]
        
        /// The total number of returned users.
        public let total: Int
        
        private enum CodingKeys: String, CodingKey {
            case users
            case total = "_total"
        }
    }
    
    public enum QueryParamKey: String {
        case login
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/users"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Users legacy request.
    public init(usernames: [String]) {
        queryParams = usernames.map { (.login, $0.lowercased()) }
    }
}
