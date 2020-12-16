//
//  PubSubChannelPointsEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub.Message {
    
    /// A PubSub event received when a custom reward is redeemed in a channel.
    public enum ChannelPointsEvent: Decodable {
        
        /// Data about a Channel Points reward.
        public struct Reward: Decodable {
            
            /// Structure containing 1x, 2x, and 4x image URLs for a Channel Points reward's image.
            public struct Image: Decodable {
                
                /// The URL for the 1x image.
                @SafeURL
                public private(set) var url1x: URL?
                
                /// The URL for the 2x image.
                @SafeURL
                public private(set) var url2x: URL?
                
                /// The URL for the 4x image.
                @SafeURL
                public private(set) var url4x: URL?
            }
            
            /// Describes whether there is a maximum total number of times a Channel Points reward may be
            /// redeemed per stream across all users/viewers and how many times that is.
            public struct MaxPerStream: Decodable {
                
                /// Whether the maximum-per-stream of a Channel Points reward is enabled or not.
                public let isEnabled: Bool
                
                /// The maximum number of times a Channel Points reward may be redeemed per stream
                /// across all users/viewers of the stream, if enabled.
                public let maxPerStream: Int
            }
            
            /// ID of the Channel Points reward.
            public let id: String
            
            /// The channel ID the reward belongs to.
            public let channelId: String
            
            /// The title of the reward.
            public let title: String
            
            /// The prompt of the reward.
            public let prompt: String
            
            /// The cost of the reward in Channel Points.
            public let cost: Int
            
            /// Whether the user needs to add any input to the reward or not.
            public let isUserInputRequired: Bool
            
            /// Whether the reward is for subscribers only or not.
            public let isSubOnly: Bool
            
            /// A set of image URLs at different resolutions for the reward.
            public let image: Image
            
            /// The default set of image URLs for the reward.
            public let defaultImage: Image
            
            /// The background color of the reward as a hex string.
            public let backgroundColor: String
            
            /// Whether the reward is enabled or not.
            public let isEnabled: Bool
            
            /// Whether the reward is paused or not.
            public let isPaused: Bool
            
            /// Whether the reward is in stock and able to be redeemed or not.
            public let isInStock: Bool
            
            /// Data describing the max-per-stream redemption rules for the reward.
            public let maxPerStream: MaxPerStream?
            
            /// Whether redemptions of the reward should skip the request queue and go straight to
            /// `.fulfilled` status or not.
            public let shouldRedemptionsSkipRequestQueue: Bool
            
            @OptionalInternetDateWithOptionalFractionalSeconds
            public private(set) var updatedForIndicatorAt: Date?
        }
        
        /// Data about a Channel Points reward redemption.
        public struct Redemption: Decodable {
            
            /// Data about a user that redeemed a Channel Points reward.
            public struct User: Decodable {
                
                /// The user ID of the user that redeemed a Channel Points reward.
                public let id: String
                
                /// The login of the user that redeemed a Channel Points reward.
                public let login: String
                
                /// The display name of the user that redeemed a Channel Points reward.
                public let displayName: String
            }
            
            /// The status of a Channel Points reward redemption.
            public enum Status: String, Decodable {
                
                /// The redemption has been accepted and fulfilled.
                case fulfilled = "FULFILLED"
                
                /// The redemption is not accepted/fulfilled.
                case unfulfilled = "UNFULFILLED"
            }
            
            /// ID of the redemption.
            public let id: String
            
            /// Data about the user that redeemed the reward.
            public let user: User
            
            /// ID of the channel in which the reward was redeemed.
            public let channelId: String
            
            /// Timestamp in which a reward was redeemed.
            @InternetDateWithFractionalSeconds
            public private(set) var redeemedAt: Date
            
            /// Data about the reward that was redeemed.
            public let reward: Reward
            
            /// A string that the user entered if the reward requires input. (Optional)
            public let userInput: String?
            
            /// Reward redemption status. Will be `.fulfilled` if a user skips the reward queue, `.unfulfilled`
            /// otherwise.
            public let status: Status
        }
        
        /// ???
        public struct RedemptionProgress: Decodable {
            
            /// ???
            public let id: String
            
            /// The channel in which the custom reward was redeemed.
            public let channelId: String
            
            /// The ID of the redeemed custom reward.
            public let rewardId: String?
            
            /// ???
            public let method: String
            
            /// The redemption's new status.
            public let newStatus: Redemption.Status
            
            /// ???
            public let processed: Int
            
            /// ???
            public let total: Int
        }
        
        /// An event relating to a redemption of a custom reward.
        public struct RedemptionEvent: Decodable {
            
            /// Time the pubsub message was sent.
            @InternetDateWithFractionalSeconds
            public private(set) var timestamp: Date
            
            /// The redemption related to this event. Includes unique ID and the user that redeemed it.
            public let redemption: Redemption
        }
        
        /// An event relating to a custom reward.
        public struct CustomRewardEvent: Decodable {
            
            /// Time the pubsub message was sent.
            @InternetDateWithFractionalSeconds
            public private(set) var timestamp: Date
            
            /// The reward that was created, updated, or deleted.
            public let reward: Reward
        }
        
        /// ???
        public struct UpdateRedemptionStatusesEvent: Decodable {
            
            /// Time the pubsub message was sent.
            @InternetDateWithFractionalSeconds
            public private(set) var timestamp: Date
            
            /// ???
            public let progress: RedemptionProgress
        }
        
        case rewardRedeemed(RedemptionEvent)
        case redemptionStatusUpdate(RedemptionEvent)
        case customRewardCreated(CustomRewardEvent)
        case customRewardUpdated(CustomRewardEvent)
        case customRewardDeleted(CustomRewardEvent)
        case updateRedemptionStatusesProgress(UpdateRedemptionStatusesEvent)
        case updateRedemptionStatusesFinished(UpdateRedemptionStatusesEvent)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "reward-redeemed":
                self = try .rewardRedeemed(container.decode(RedemptionEvent.self, forKey: .data))
                
            case "redemption-status-update":
                self = try .redemptionStatusUpdate(container.decode(RedemptionEvent.self, forKey: .data))
                
            case "custom-reward-created":
                self = try .customRewardCreated(container.decode(CustomRewardEvent.self, forKey: .data))
                
            case "custom-reward-updated":
                self = try .customRewardUpdated(container.decode(CustomRewardEvent.self, forKey: .data))
                
            case "custom-reward-deleted":
                self = try .customRewardDeleted(container.decode(CustomRewardEvent.self, forKey: .data))
                
            case "update-redemption-statuses-progress":
                self = try .updateRedemptionStatusesProgress(
                    container.decode(UpdateRedemptionStatusesEvent.self, forKey: .data)
                )
                
            case "update-redemption-statuses-finished":
                self = try .updateRedemptionStatusesFinished(
                    container.decode(UpdateRedemptionStatusesEvent.self, forKey: .data)
                )
                
            default:
                throw DecodingError.dataCorruptedError(forKey: .type,
                                                       in: container,
                                                       debugDescription: "Unknown channel points event type")
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case type
            case data
        }
    }
}
