//
//  LegacySearchGamesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Searches for games based on a specified query parameter.
///
/// A game is returned if the query parameter is matched entirely or partially, in the game name.
public struct LegacySearchGamesRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The list of games that satisfy the search query.
        public let games: [LegacyGame]
    }
    
    public enum QueryParamKey: String {
        case query
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/search/games"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Search Games legacy request.
    ///
    /// - Parameter query: The search query.
    public init(query: String) {
        queryParams = [(.query, query)]
    }
}
