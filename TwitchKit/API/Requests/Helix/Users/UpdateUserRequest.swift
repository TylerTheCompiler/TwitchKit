//
//  UpdateUserRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Updates the description of a user specified by a Bearer token.
public struct UpdateUserRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = GetUsersRequest.ResponseBody
    
    public enum QueryParamKey: String {
        case description
    }
    
    public let method: HTTPMethod = .put
    public let path = "/users"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Update User request.
    ///
    /// - Parameter description: User's account description.
    public init(description: String? = nil) {
        queryParams = [(.description, description)]
    }
}
