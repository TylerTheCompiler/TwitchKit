//
//  GetChannelTeamsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// Retrieves a list of Twitch Teams of which the specified channel/broadcaster is a member.
public struct GetChannelTeamsRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The list of Twitch teams of which the specified channel/broadcaster is a member.
        @EmptyIfNull
        public private(set) var teams: [Team]
        
        private enum CodingKeys: String, CodingKey {
            case teams = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/teams/channel"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel Teams request.
    ///
    /// - Parameter broadcasterId: User ID for a Twitch user.
    public init(broadcasterId: String) {
        queryParams = [(.broadcasterId, broadcasterId)]
    }
}
