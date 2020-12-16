//
//  GetCustomRewardsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// Returns a list of Custom Reward objects for the Custom Rewards on a channel. Developers only have access to
/// update and delete rewards that the same/calling client ID created.
public struct GetCustomRewardsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned custom rewards.
        public let customRewards: [CustomChannelPointsReward]
        
        private enum CodingKeys: String, CodingKey {
            case customRewards = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case id
        case onlyManageableRewards = "only_manageable_rewards"
    }
    
    public let path = "/channel_points/custom_rewards"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Custom Rewards request.
    ///
    /// - Parameters:
    ///   - customRewardIds: When used, this parameter filters the results and only returns reward objects for the
    ///                      Custom Rewards with matching ID. Maximum: 50 IDs.
    ///   - onlyManageableRewards: When set to true, only returns custom rewards that the calling client ID can manage.
    ///                            Default: false.
    public init(customRewardIds: [String] = [], onlyManageableRewards: Bool? = nil) {
        queryParams = [
            (.onlyManageableRewards, onlyManageableRewards?.description)
        ] + customRewardIds.map { (.id, $0) }
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
