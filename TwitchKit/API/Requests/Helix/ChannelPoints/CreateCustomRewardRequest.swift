//
//  CreateCustomRewardRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// Creates a Custom Reward on a channel.
public struct CreateCustomRewardRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The title of the reward
        public let title: String
        
        /// The cost of the reward
        public let cost: Int
        
        /// The prompt for the viewer when they are redeeming the reward
        public let prompt: String?
        
        /// Is the reward currently enabled, if false the reward won't show up to viewers. Defaults true
        public let isEnabled: Bool?
        
        /// Custom background color for the reward. Format: Hex with # prefix. Example: #00E5CB.
        public let backgroundColor: String?
        
        /// Does the user need to enter information when redeeming the reward. Defaults false
        public let isUserInputRequired: Bool?
        
        /// Whether a maximum per stream is enabled. Defaults to false.
        public let isMaxPerStreamEnabled: Bool?
        
        /// The maximum number per stream if enabled
        public let maxPerStream: Int?
        
        /// Whether a maximum per user per stream is enabled. Defaults to false.
        public let isMaxPerUserPerStreamEnabled: Bool?
        
        /// The maximum number per user per stream if enabled
        public let maxPerUserPerStream: Int?
        
        /// Whether a cooldown is enabled. Defaults to false.
        public let isGlobalCooldownEnabled: Bool?
        
        /// The cooldown in seconds if enabled
        public let globalCooldownSeconds: Int?
        
        /// Should redemptions be set to FULFILLED status immediately when redeemed and skip the request queue
        /// instead of the normal UNFULFILLED status. Defaults false
        public let shouldRedemptionsSkipRequestQueue: Bool?
    }
    
    public struct ResponseBody: Decodable {
        
        /// An array of one object - the created custom reward.
        public let customRewards: [CustomChannelPointsReward]
        
        private enum CodingKeys: String, CodingKey {
            case customRewards = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let method: HTTPMethod = .post
    public let path = "/channel_points/custom_rewards"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    public let body: RequestBody?
    
    /// Creates a new Create Custom Reward request with the given parameters. Only `title` and `cost` are required
    /// parameters.
    ///
    /// - Parameters:
    ///   - title: The title of the reward.
    ///   - cost: The cost of the reward in channel points.
    ///   - prompt: The prompt for the viewer when they are redeeming the reward.
    ///   - isEnabled: Whether the reward is currently enabled. If false, the reward won't show up to viewers.
    ///                Default: true.
    ///   - backgroundColor: Custom background color for the reward. Format: Hex with # prefix. Example: #00E5CB.
    ///   - isUserInputRequired: Whether the user need to enter information when redeeming the reward. Default: false.
    ///   - isMaxPerStreamEnabled: Whether a maximum per stream is enabled. Default: false.
    ///   - maxPerStream: The maximum number of redemptions per stream if enabled.
    ///   - isMaxPerUserPerStreamEnabled: Whether a maximum per user per stream is enabled. Default: false.
    ///   - maxPerUserPerStream: The maximum number of redemptions per user per stream if enabled.
    ///   - isGlobalCooldownEnabled: Whether a cooldown is enabled. Default: false.
    ///   - globalCooldownSeconds: The global cooldown in seconds if enabled.
    ///   - shouldRedemptionsSkipRequestQueue: Whether redemptions should be set to FULFILLED status immediately when
    ///                                        redeemed and skip the request queue instead of the normal UNFULFILLED
    ///                                        status. Default: false.
    public init(title: String,
                cost: Int,
                prompt: String? = nil,
                isEnabled: Bool? = nil,
                backgroundColor: String? = nil,
                isUserInputRequired: Bool? = nil,
                isMaxPerStreamEnabled: Bool? = nil,
                maxPerStream: Int? = nil,
                isMaxPerUserPerStreamEnabled: Bool? = nil,
                maxPerUserPerStream: Int? = nil,
                isGlobalCooldownEnabled: Bool? = nil,
                globalCooldownSeconds: Int? = nil,
                shouldRedemptionsSkipRequestQueue: Bool? = nil) {
        queryParams = []
        body = .init(
            title: title,
            cost: cost,
            prompt: prompt,
            isEnabled: isEnabled,
            backgroundColor: backgroundColor,
            isUserInputRequired: isUserInputRequired,
            isMaxPerStreamEnabled: isMaxPerStreamEnabled,
            maxPerStream: maxPerStream,
            isMaxPerUserPerStreamEnabled: isMaxPerUserPerStreamEnabled,
            maxPerUserPerStream: maxPerUserPerStream,
            isGlobalCooldownEnabled: isGlobalCooldownEnabled,
            globalCooldownSeconds: globalCooldownSeconds,
            shouldRedemptionsSkipRequestQueue: shouldRedemptionsSkipRequestQueue
        )
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
