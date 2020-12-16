//
//  DeleteCustomRewardRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// Deletes a Custom Reward on a channel.
///
/// Only rewards created by the same client_id can be deleted. Any UNFULFILLED Custom Reward Redemptions of the
/// deleted Custom Reward will be updated to the FULFILLED status.
public struct DeleteCustomRewardRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case id
    }
    
    public let method: HTTPMethod = .delete
    public let path = "/channel_points/custom_rewards"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Delete Custom Reward request.
    ///
    /// - Parameter customRewardId: ID of the Custom Reward to delete. Must match a Custom Reward on the channel
    ///                             attached to the user access token.
    public init(customRewardId: String) {
        queryParams = [(.id, customRewardId)]
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
