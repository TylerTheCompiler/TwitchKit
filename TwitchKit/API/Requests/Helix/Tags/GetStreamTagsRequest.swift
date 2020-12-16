//
//  GetStreamTagsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets the list of tags for a specified stream (channel).
public struct GetStreamTagsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of stream tags.
        public let tags: [StreamTag]
        
        private enum CodingKeys: String, CodingKey {
            case tags = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/streams/tags"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Stream Tags request.
    ///
    /// - Parameter broadcasterId: ID of the stream thats tags are going to be fetched.
    public init(broadcasterId: String) {
        queryParams = [(.broadcasterId, broadcasterId)]
    }
}
