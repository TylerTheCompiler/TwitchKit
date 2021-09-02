//
//  GetCreatorGoalsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 9/1/21.
//

/// Gets the broadcaster's list of active goals.
///
/// Use this to get the current progress of each goal.
public struct GetCreatorGoalsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// An array of creator goals.
        ///
        /// Currently, the array contains at most one goal. The array is empty if the broadcaster hasn't created goals.
        public let goals: [Goal]
        
        private enum CodingKeys: String, CodingKey {
            case goals = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/goals"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Creator Goals request for the current authenticated user.
    public init() {
        queryParams = []
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
