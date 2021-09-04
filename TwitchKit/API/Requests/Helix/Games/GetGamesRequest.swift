//
//  GetGamesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets game information by game ID or name.
public struct GetGamesRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The returned list of games.
        public let games: [Game]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case games = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case before
        case first
        case id
        case name
    }
    
    public let path = "/games"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Games request.
    ///
    /// - Parameters:
    ///   - gameIds: Game IDs. At most 100 ID values can be specified.
    ///   - gameNames: Game names. The names must be exact matches. For example, "Pokemon" will not return a list of
    ///                Pokemon games; instead, query any specific Pokemon games in which you are interested. At most
    ///                100 name values can be specified.
    ///   - cursor: Cursor for forward pagination.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    public init(gameIds: [String] = [],
                gameNames: [String] = [],
                cursor: Pagination.DirectedCursor? = nil,
                first: Int? = nil) {
        queryParams = [
            (.after, cursor?.forwardRawValue),
            (.before, cursor?.backwardRawValue),
            (.first, first?.description)
        ] + gameIds.map {
            (.id, $0)
        } + gameNames.map {
            (.name, $0)
        }
    }
}
