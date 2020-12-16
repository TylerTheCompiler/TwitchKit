//
//  GetCustomRewardRedemptionsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// Returns Custom Reward Redemption objects for a Custom Reward on a channel that was created by the same client ID.
/// Developers only have access to get and update redemptions for the rewards they created.
public struct GetCustomRewardRedemptionsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned custom reward redemptions.
        public let redemptions: [CustomChannelPointsReward.Redemption]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case redemptions = "data"
            case cursor = "pagination"
        }
    }
    
    /// The order that custom reward redemptions should be returned in.
    public enum SortOrder: String {
        
        /// The oldest redemptions show up first.
        case oldest = "OLDEST"
        
        /// The newest redemptions show up first.
        case newest = "NEWEST"
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case rewardId = "reward_id"
        case id
        case status
        case sort
        case after
        case first
    }
    
    public let path = "/channel_points/custom_rewards/redemptions"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Custom Reward Redemptions request for a specific set of redemptions.
    ///
    /// - Parameters:
    ///   - rewardId: The ID of the custom reward that the redemptions specified by `redemptionIds` belong to.
    ///   - redemptionIds: Filters the results and only returns Custom Reward Redemption objects for the redemptions
    ///                    with matching ID. Maximum: 50 IDs.
    public init(rewardId: String, redemptionIds: [String]) {
        self.init(rewardId: rewardId,
                  redemptionIds: redemptionIds,
                  status: nil,
                  sortBy: nil,
                  after: nil,
                  first: nil)
    }
    
    /// Creates a new Get Custom Reward Redemptions request.
    ///
    /// - Parameters:
    ///   - rewardId: This parameter returns paginated Custom Reward Redemption objects for redemptions of the Custom
    ///               Reward with ID `rewardId`.
    ///   - status: Filters the paginated Custom Reward Redemption objects for redemptions with the matching status.
    ///   - sortOrder: Sort order of redemptions returned when getting the paginated Custom Reward Redemption objects
    ///                for a reward. Default: `.oldest`.
    ///   - first: Number of results to be returned when getting the paginated Custom Reward Redemption objects for a
    ///            reward. Limit: 50. Default: 20.
    public init(rewardId: String,
                status: CustomChannelPointsReward.Redemption.Status,
                sortBy sortOrder: SortOrder? = nil,
                first: Int? = nil) {
        self.init(rewardId: rewardId,
                  redemptionIds: [],
                  status: status,
                  sortBy: sortOrder,
                  after: nil,
                  first: first)
    }
    
    /// Creates a new Get Custom Reward Redemptions request with a pagination cursor.
    ///
    /// - Parameters:
    ///   - after: Cursor for forward pagination: tells the server where to start fetching the next set of results, in
    ///            a multi-page response. This applies only to queries that don't use `redemptionIds`.
    ///            The cursor value specified here is from the pagination response field of a prior query.
    ///   - first: Number of results to be returned when getting the paginated Custom Reward Redemption objects for a
    ///            reward. Limit: 50. Default: 20.
    public init(after: Pagination.Cursor, first: Int? = nil) {
        self.init(rewardId: nil,
                  redemptionIds: [],
                  status: nil,
                  sortBy: nil,
                  after: after,
                  first: first)
    }
    
    private init(rewardId: String?,
                 redemptionIds: [String],
                 status: CustomChannelPointsReward.Redemption.Status?,
                 sortBy sort: SortOrder?,
                 after: Pagination.Cursor?,
                 first: Int?) {
        queryParams = [
            (.rewardId, rewardId),
            (.status, status?.rawValue),
            (.sort, sort?.rawValue),
            (.after, after?.rawValue),
            (.first, first?.description)
        ] + redemptionIds.map { (.id, $0) }
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
