//
//  EventSubSubscriptionCondition.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub {
    
    /// Subscription-specific parameters. The parameters inside this object differ by subscription
    /// type and may differ by version.
    public enum SubscriptionCondition: Equatable, Encodable {
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get updates for.
        case channelUpdate(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get follow
        ///                      notifications for.
        case channelFollow(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get subscribe
        ///                      notifications for.
        case channelSubscribe(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get cheer
        ///                      notifications for.
        case channelCheer(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get ban
        ///                      notifications for.
        case channelBan(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get unban
        ///                      notifications for.
        case channelUnban(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to receive channel
        ///                      points custom reward add notifications for.
        case channelPointsCustomRewardAdd(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to receive channel
        ///                      points custom reward update notifications for.
        /// - rewardId: Optional. Specify a reward id to only receive notifications for a specific reward.
        case channelPointsCustomRewardUpdate(broadcasterUserId: String, rewardId: String? = nil)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to receive channel
        ///                      points custom reward remove notifications for.
        /// - rewardId: Optional. Specify a reward id to only receive notifications for a specific reward.
        case channelPointsCustomRewardRemove(broadcasterUserId: String, rewardId: String? = nil)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to receive channel
        ///                      points custom reward redemption add notifications for.
        /// - rewardId: Optional. Specify a reward id to only receive notifications for a specific reward.
        case channelPointsCustomRewardRedemptionAdd(broadcasterUserId: String, rewardId: String? = nil)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to receive channel
        ///                      points custom reward redemption update notifications for.
        /// - rewardId: Optional. Specify a reward id to only receive notifications for a specific reward.
        case channelPointsCustomRewardRedemptionUpdate(broadcasterUserId: String, rewardId: String? = nil)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to hype train begin
        ///                      notifications for.
        case hypeTrainBegin(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to hype train
        ///                      progress notifications for.
        case hypeTrainProgress(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to hype train end
        ///                      notifications for.
        case hypeTrainEnd(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID you want to get stream online notifications for.
        case streamOnline(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID you want to get stream offline notifications for.
        case streamOffline(broadcasterUserId: String)
        
        /// - clientId: Your application's client ID. The provided client ID must match the client ID in the
        /// application access token.
        case userAuthorizationRevoke(clientId: String)
        
        /// - userId: The user ID for the user you want update notifications for.
        case userUpdate(userId: String)
        
        /// The type of subscription this condition applies to.
        public var subscriptionType: SubscriptionType {
            switch self {
            case .channelUpdate: return .channelUpdate
            case .channelFollow: return .channelFollow
            case .channelSubscribe: return .channelSubscribe
            case .channelCheer: return .channelCheer
            case .channelBan: return .channelBan
            case .channelUnban: return .channelUnban
            case .channelPointsCustomRewardAdd: return .channelPointsCustomRewardAdd
            case .channelPointsCustomRewardUpdate: return .channelPointsCustomRewardUpdate
            case .channelPointsCustomRewardRemove: return .channelPointsCustomRewardRemove
            case .channelPointsCustomRewardRedemptionAdd: return .channelPointsCustomRewardRedemptionAdd
            case .channelPointsCustomRewardRedemptionUpdate: return .channelPointsCustomRewardRedemptionUpdate
            case .hypeTrainBegin: return .hypeTrainBegin
            case .hypeTrainProgress: return .hypeTrainProgress
            case .hypeTrainEnd: return .hypeTrainEnd
            case .streamOnline: return .streamOnline
            case .streamOffline: return .streamOffline
            case .userAuthorizationRevoke: return .userAuthorizationRevoke
            case .userUpdate: return .userUpdate
            }
        }
        
        internal init(from container: KeyedDecodingContainer<CodingKeys>,
                      subscriptionType: SubscriptionType) throws {
            func broadcasterUserId() throws -> String {
                try container.decode(String.self, forKey: .broadcasterUserId)
            }
            
            func rewardId() throws -> String? {
                try container.decodeIfPresent(String.self, forKey: .rewardId)
            }
            
            func clientId() throws -> String { try container.decode(String.self, forKey: .clientId) }
            func userId() throws -> String { try container.decode(String.self, forKey: .userId) }
            
            switch subscriptionType {
            case .channelBan:
                self = try .channelBan(broadcasterUserId: broadcasterUserId())
            case .channelSubscribe:
                self = try .channelSubscribe(broadcasterUserId: broadcasterUserId())
            case .channelCheer:
                self = try .channelCheer(broadcasterUserId: broadcasterUserId())
            case .channelUpdate:
                self = try .channelUpdate(broadcasterUserId: broadcasterUserId())
            case .channelFollow:
                self = try .channelFollow(broadcasterUserId: broadcasterUserId())
            case .channelUnban:
                self = try .channelUnban(broadcasterUserId: broadcasterUserId())
            case .channelPointsCustomRewardAdd:
                self = try .channelPointsCustomRewardAdd(broadcasterUserId: broadcasterUserId())
            case .channelPointsCustomRewardUpdate:
                self = try .channelPointsCustomRewardUpdate(broadcasterUserId: broadcasterUserId(),
                                                            rewardId: rewardId())
            case .channelPointsCustomRewardRemove:
                self = try .channelPointsCustomRewardRemove(broadcasterUserId: broadcasterUserId(),
                                                            rewardId: rewardId())
            case .channelPointsCustomRewardRedemptionAdd:
                self = try .channelPointsCustomRewardRedemptionAdd(broadcasterUserId: broadcasterUserId(),
                                                                   rewardId: rewardId())
            case .channelPointsCustomRewardRedemptionUpdate:
                self = try .channelPointsCustomRewardRedemptionUpdate(broadcasterUserId: broadcasterUserId(),
                                                                      rewardId: rewardId())
            case .hypeTrainBegin:
                self = try .hypeTrainBegin(broadcasterUserId: broadcasterUserId())
            case .hypeTrainProgress:
                self = try .hypeTrainProgress(broadcasterUserId: broadcasterUserId())
            case .hypeTrainEnd:
                self = try .hypeTrainEnd(broadcasterUserId: broadcasterUserId())
            case .streamOnline:
                self = try .streamOnline(broadcasterUserId: broadcasterUserId())
            case .streamOffline:
                self = try .streamOffline(broadcasterUserId: broadcasterUserId())
            case .userAuthorizationRevoke:
                self = try .userAuthorizationRevoke(clientId: clientId())
            case .userUpdate:
                self = try .userUpdate(userId: userId())
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .channelUpdate(let broadcasterUserId),
                 .channelFollow(let broadcasterUserId),
                 .channelSubscribe(let broadcasterUserId),
                 .channelCheer(let broadcasterUserId),
                 .channelBan(let broadcasterUserId),
                 .channelUnban(let broadcasterUserId),
                 .hypeTrainBegin(let broadcasterUserId),
                 .hypeTrainProgress(let broadcasterUserId),
                 .hypeTrainEnd(let broadcasterUserId),
                 .streamOnline(let broadcasterUserId),
                 .streamOffline(let broadcasterUserId),
                 .channelPointsCustomRewardAdd(let broadcasterUserId):
                try container.encode(broadcasterUserId, forKey: .broadcasterUserId)
                
            case .channelPointsCustomRewardUpdate(let broadcasterUserId, let rewardId),
                 .channelPointsCustomRewardRemove(let broadcasterUserId, let rewardId),
                 .channelPointsCustomRewardRedemptionAdd(let broadcasterUserId, let rewardId),
                 .channelPointsCustomRewardRedemptionUpdate(let broadcasterUserId, let rewardId):
                try container.encode(broadcasterUserId, forKey: .broadcasterUserId)
                try container.encodeIfPresent(rewardId, forKey: .rewardId)
                
            case .userAuthorizationRevoke(let clientId):
                try container.encode(clientId, forKey: .clientId)
                
            case .userUpdate(let userId):
                try container.encode(userId, forKey: .userId)
            }
        }
        
        internal enum CodingKeys: String, CodingKey {
            case broadcasterUserId
            case rewardId
            case clientId
            case userId
        }
    }
}
