//
//  GetChannelInformationRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets channel information for users.
public struct GetChannelInformationRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// An array of one object - the returned channel information.
        @ArrayOfOne
        public private(set) var channelInformation: ChannelInformation
        
        private enum CodingKeys: String, CodingKey {
            case channelInformation = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/channels"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel Information request.
    ///
    /// - Parameter broadcasterId: ID of the channel whose information you want to retrieve.
    public init(broadcasterId: String) {
        queryParams = [(.broadcasterId, broadcasterId)]
    }
}
