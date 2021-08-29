//
//  GetTeamRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// Gets information for a specific Twitch Team.
public struct GetTeamRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The requested Twitch team.
        @ArrayOfOne
        public private(set) var team: Team
        
        private enum CodingKeys: String, CodingKey {
            case team = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case name
        case id
    }
    
    public let path = "/teams"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Team request.
    ///
    /// - Parameter teamName: The name of the team to return.
    public init(teamName: String) {
        queryParams = [(.name, teamName)]
    }
    
    /// Creates a new Get Team request.
    ///
    /// - Parameter teamId: The ID of the team to return.
    public init(teamId: String) {
        queryParams = [(.id, teamId)]
    }
}
