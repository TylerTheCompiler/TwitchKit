//
//  EventSubChannelPointsCustomReward.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct ChannelPointsCustomReward: Decodable {
        
        /// <#Description#>
        public struct MaxPerStream: Decodable {
            
            /// Is the setting enabled.
            public let isEnabled: Bool
            
            /// The max per stream limit.
            public let value: Int
        }
        
        /// <#Description#>
        public struct MaxPerUserPerStream: Decodable {
            
            /// Is the setting enabled.
            public let isEnabled: Bool
            
            /// The max per user per stream limit.
            public let value: Int
        }
        
        /// <#Description#>
        public struct Image: Decodable {
            
            /// URL for the image at 1x size.
            @SafeURL
            public private(set) var url1x: URL?
            
            /// URL for the image at 2x size.
            @SafeURL
            public private(set) var url2x: URL?
            
            /// URL for the image at 4x size.
            @SafeURL
            public private(set) var url4x: URL?
        }
        
        /// <#Description#>
        public struct GlobalCooldown: Decodable {
            
            /// Is the setting enabled.
            public let isEnabled: Bool
            
            /// The cooldown in seconds.
            public let seconds: Int
        }
        
        /// The reward identifier.
        public let id: String
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster name.
        public let broadcasterUserName: String
        
        /// Is the reward currently enabled. If false, the reward won't show up to viewers.
        public let isEnabled: Bool
        
        /// Is the reward currently paused. If true, viewers can't redeem.
        public let isPaused: Bool
        
        /// Is the reward currently in stock. If false, viewers can't redeem.
        public let isInStock: Bool
        
        /// The reward title.
        public let title: String
        
        /// The reward cost.
        public let cost: Int
        
        /// The reward description.
        public let prompt: String
        
        /// Does the viewer need to enter information when redeeming the reward.
        public let isUserInputRequired: Bool
        
        /// Should redemptions be set to fulfilled status immediately when redeemed and skip the request queue
        /// instead of the normal unfulfilled status.
        public let shouldRedemptionsSkipRequestQueue: Bool
        
        /// Whether a maximum per stream is enabled and what the maximum is.
        public let maxPerStream: MaxPerStream
        
        /// Whether a maximum per user per stream is enabled and what the maximum is.
        public let maxPerUserPerStream: MaxPerUserPerStream
        
        /// Custom background color for the reward. Format: Hex with # prefix. Example: #FA1ED2.
        public let backgroundColor: String
        
        /// Set of custom images of 1x, 2x and 4x sizes for the reward. Can be nil if no images have been
        /// uploaded.
        public let image: Image?
        
        /// Set of default images of 1x, 2x and 4x sizes for the reward.
        public let defaultImage: Image
        
        /// Whether a cooldown is enabled and what the cooldown is in seconds.
        public let globalCooldown: GlobalCooldown
        
        /// Timestamp of the cooldown expiration. Nil if the reward isn't on cooldown.
        @OptionalInternetDateWithOptionalFractionalSeconds
        public private(set) var cooldownExpiresAt: Date?
        
        /// The number of redemptions redeemed during the current live stream. Counts against the
        /// `maxPerStream` limit. Nil if the broadcasters stream isn't live or `maxPerStream` isn't enabled.
        public let redemptionsRedeemedCurrentStream: Int?
    }
}
