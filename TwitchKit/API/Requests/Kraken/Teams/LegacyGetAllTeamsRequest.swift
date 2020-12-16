//
//  LegacyGetAllTeamsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets all active teams.
public struct LegacyGetAllTeamsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of active teams.
        public let teams: [LegacyTeam]
    }
    
    public enum QueryParamKey: String {
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/teams"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get All Teams legacy request.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of objects to return, sorted by creation date. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0.
    public init(limit: Int? = nil, offset: Int? = nil) {
        queryParams = [
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
