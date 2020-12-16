//
//  LegacyGetTopGamesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets games sorted by number of current viewers on Twitch, most popular first.
public struct LegacyGetTopGamesRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returns list of top games.
        public let games: [LegacyGameInfo]
        
        /// The total number of returned games.
        public let total: Int?
        
        private enum CodingKeys: String, CodingKey {
            case games = "top"
            case total = "_total"
        }
    }
    
    public enum QueryParamKey: String {
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/games/top"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Top Games legacy request.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of objects to return. Default: 10. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0.
    public init(limit: Int? = nil, offset: Int? = nil) {
        queryParams = [
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
