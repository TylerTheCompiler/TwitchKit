//
//  GetStreamKeyRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets the channel stream key for a user.
public struct GetStreamKeyRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// An array of one object - the authenticated user's stream key.
        public let streamKeys: [StreamKey]
        
        private enum CodingKeys: String, CodingKey {
            case streamKeys = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/streams/key"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Stream Key request.
    public init() {
        queryParams = []
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
