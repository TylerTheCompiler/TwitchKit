//
//  GetTopGamesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets games sorted by number of current viewers on Twitch, most popular first.
public struct GetTopGamesRequest: APIRequest {
    public typealias ResponseBody = GetGamesRequest.ResponseBody
    
    public enum QueryParamKey: String {
        case after
        case before
        case first
    }
    
    public let path = "/games/top"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Top Games request.
    ///
    /// - Parameters:
    ///   - cursor: Cursor for forward or backward pagination.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(cursor: Pagination.DirectedCursor? = nil, first: Int? = nil) {
        queryParams = [
            (.after, cursor?.forwardRawValue),
            (.before, cursor?.backwardRawValue),
            (.first, first?.description)
        ]
    }
}
