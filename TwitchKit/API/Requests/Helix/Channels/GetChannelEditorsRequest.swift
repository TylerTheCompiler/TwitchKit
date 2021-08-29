//
//  GetChannelEditorsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/28/21.
//

/// Gets a list of users who have editor permissions for a specific channel.
public struct GetChannelEditorsRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The editors belonging to the broadcaster associated with the channel.
        public let editors: [Editor]
        
        private enum CodingKeys: String, CodingKey {
            case editors = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/channels/editors"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel Editors request.
    ///
    /// - Parameter broadcasterId: Broadcaster's user ID associated with the channel.
    public init(broadcasterId: String) {
        queryParams = [(.broadcasterId, broadcasterId)]
    }
}
