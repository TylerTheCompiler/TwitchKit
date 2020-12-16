//
//  CustomChannelPointsReward.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// A custom channel points reward.
public struct CustomChannelPointsReward: Decodable {
    
    /// Set of custom images of 1x, 2x and 4x sizes for the reward.
    public struct Image: Decodable {
        
        /// The URL of the image scaled to 1x size.
        @SafeURL
        public private(set) var url1x: URL?
        
        /// The URL of the image scaled to 2x size.
        @SafeURL
        public private(set) var url2x: URL?
        
        /// The URL of the image scaled to 4x size.
        @SafeURL
        public private(set) var url4x: URL?
    }
    
    /// Whether a maximum per stream is enabled and what the maximum is.
    public struct MaxPerStream: Decodable {
        
        /// Whether a maximum per stream is enabled.
        public let isEnabled: Bool
        
        /// The maximum number of times a custom reward may be redeemed during one stream of a channel.
        public let maxPerStream: Int
    }
    
    /// Whether a maximum per user per stream is enabled and what the maximum is.
    public struct MaxPerUserPerStream: Decodable {
        
        /// Whether a maximum per user per stream is enabled.
        public let isEnabled: Bool
        
        /// The maximum number of times a custom reward may be redeemed per user during one channel's stream.
        public let maxPerUserPerStream: Int
    }
    
    /// Whether a cooldown is enabled and what the cooldown is.
    public struct GlobalCooldown: Decodable {
        
        /// Whether a cooldown is enabled.
        public let isEnabled: Bool
        
        /// The number of seconds users must wait between redeeming the custom reward and redeeming it again.
        public let globalCooldownSeconds: Int
    }
    
    /// ID of the channel the reward is for.
    public let broadcasterId: String
    
    /// Display name of the channel the reward is for.
    public let broadcasterName: String
    
    /// ID of the reward.
    public let id: String
    
    /// The title of the reward.
    public let title: String
    
    /// The prompt for the viewer when they are redeeming the reward.
    public let prompt: String
    
    /// The cost of the reward in channel points.
    public let cost: Int
    
    /// A set of custom images of 1x, 2x and 4x sizes for the reward. Can be nil if no images have been uploaded.
    public let image: Image?
    
    /// A set of default images of 1x, 2x and 4x sizes for the reward.
    public let defaultImage: Image
    
    /// Custom background color for the reward. Format: Hex with # prefix. Example: #00E5CB.
    public let backgroundColor: String
    
    /// Whether the reward is currently enabled. If false, the reward won’t show up to viewers.
    public let isEnabled: Bool
    
    /// Whether the user needs to enter information when redeeming the reward.
    public let isUserInputRequired: Bool
    
    /// Whether a maximum per stream is enabled and what the maximum is.
    public let maxPerStreamSetting: MaxPerStream
    
    /// Whether a maximum per user per stream is enabled and what the maximum is.
    public let maxPerUserPerStreamSetting: MaxPerUserPerStream
    
    /// Whether a cooldown is enabled and what the cooldown is.
    public let globalCooldownSetting: GlobalCooldown
    
    /// Whether the reward is currently paused. If true, viewers can’t redeem the reward.
    public let isPaused: Bool
    
    /// Whether the reward is currently in stock. If false, viewers can’t redeem the reward.
    public let isInStock: Bool
    
    /// Whether redemptions should be set to FULFILLED status immediately when redeemed and skip the request
    /// queue instead of the normal UNFULFILLED status.
    public let shouldRedemptionsSkipRequestQueue: Bool
    
    /// The number of redemptions redeemed during the current live stream. Counts against the
    /// `maxPerStreamSetting` limit. Nil if the broadcasters stream isn’t live or `maxPerStreamSetting`
    /// isn’t enabled.
    public let redemptionsRedeemedCurrentStream: Int?
    
    /// Timestamp of the cooldown expiration. Nil if the reward isn’t on cooldown.
    @OptionalInternetDateWithOptionalFractionalSeconds
    public private(set) var cooldownExpiresAt: Date?
}
