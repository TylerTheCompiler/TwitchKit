//
//  SearchCategoriesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Returns a list of games or categories that match the query via name either entirely or partially.
public struct SearchCategoriesRequest: APIRequest {
    public typealias ResponseBody = GetGamesRequest.ResponseBody
    
    public enum QueryParamKey: String {
        case after
        case first
        case query
    }
    
    public let path = "/search/categories"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Search Categories request.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - after: Cursor for forward pagination.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(query: String,
                after: Pagination.Cursor? = nil,
                first: Int? = nil) {
        queryParams = [
            (.query, query),
            (.after, after?.rawValue),
            (.first, first?.description)
        ]
    }
}
