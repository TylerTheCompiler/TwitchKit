//
//  UpdateCustomRewardRedemptionStatusRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// Updates the status of Custom Reward Redemption objects on a channel that are in the UNFULFILLED status.
///
/// Only redemptions for a reward created by the same client ID as attached to the access token can be updated.
public struct UpdateCustomRewardRedemptionStatusRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The new status to set redemptions to. Can be either `.fulfilled` or `.canceled`.
        /// Updating to `.canceled` will refund the user their points.
        public let status: CustomChannelPointsReward.Redemption.Status
    }
    
    public struct ResponseBody: Decodable {
        
        /// The updated custom reward redemptions.
        public let redemptions: [CustomChannelPointsReward.Redemption]
        
        private enum CodingKeys: String, CodingKey {
            case redemptions = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case id
        case broadcasterId = "broadcaster_id"
        case rewardId = "reward_id"
    }
    
    public let method: HTTPMethod = .patch
    public let path = "/channel_points/custom_rewards/redemptions"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    public let body: RequestBody?
    
    /// Creates a new Update Custom Reward Redemption Status request.
    ///
    /// - Parameters:
    ///   - redemptionIds: IDs of the Custom Reward Redemptions to update.
    ///   - rewardId: ID of the Custom Reward the redemptions to be updated are for.
    ///   - status: The new status to set redemptions to. Can be either `.fulfilled` or `.canceled`.
    ///             Updating to `.canceled` will refund the user their points.
    public init(redemptionIds: [String],
                rewardId: String,
                status: CustomChannelPointsReward.Redemption.Status) {
        queryParams = [
            (.rewardId, rewardId)
        ] + redemptionIds.map { (.id, $0) }
        body = .init(status: status)
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
