//
//  EventSubSubscriptionCondition.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub {
    
    public enum RaidBroadcasterUserId: Equatable {
        case to(broadcasterUserId: String) // swiftlint:disable:this identifier_name
        case from(broadcasterUserId: String)
    }
    
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
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get subscription
        ///                      end notifications for.
        case channelSubscriptionEnd(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get subscription
        ///                      gift notifications for.
        case channelSubscriptionGift(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get resubscription
        ///                      chat message notifications for.
        case channelSubscriptionMessage(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get cheer
        ///                      notifications for.
        case channelCheer(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get cheer
        ///                      notifications for.
        case channelRaid(broadcasterUserId: RaidBroadcasterUserId)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get ban
        ///                      notifications for.
        case channelBan(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get unban
        ///                      notifications for.
        case channelUnban(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get moderator
        ///                      addition notifications for.
        case channelModeratorAdd(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID for the channel you want to get moderator
        ///                      removal notifications for.
        case channelModeratorRemove(broadcasterUserId: String)
        
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
        
        /// - broadcasterUserId: The broadcaster user ID of the channel for which "poll begin" notifications
        ///                      will be received.
        case channelPollBegin(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID of the channel for which "poll progress" notifications
        ///                      will be received.
        case channelPollProgress(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID of the channel for which "poll end" notifications
        ///                      will be received.
        case channelPollEnd(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID of the channel for which "prediction begin" notifications
        ///                      will be received.
        case channelPredictionBegin(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID of the channel for which "prediction progress" notifications
        ///                      will be received.
        case channelPredictionProgress(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID of the channel for which "prediction lock" notifications
        ///                      will be received.
        case channelPredictionLock(broadcasterUserId: String)
        
        /// - broadcasterUserId: The broadcaster user ID of the channel for which "prediction end" notifications
        ///                      will be received.
        case channelPredictionEnd(broadcasterUserId: String)
        
        /// - organizationId: The organization ID of the organization that owns the game on the developer portal.
        /// - categoryId: The category (or game) ID of the game for which entitlement notifications will be received.
        /// - campaignId: The campaign ID for a specific campaign for which entitlement notifications will be received.
        case dropEntitlementGrant(organizationId: String,
                                  categoryId: String?,
                                  campaignId: String?)
        
        /// - extensionClientId: The client ID of the extension.
        case extensionBitsTransactionCreate(extensionClientId: String)
        
        /// - broadcasterUserId: The ID of the broadcaster to get notified about. The ID must match the user ID
        ///                      in the OAuth access token.
        case channelGoalsBegin(broadcasterUserId: String)
        
        /// - broadcasterUserId: The ID of the broadcaster to get notified about. The ID must match the user ID
        ///                      in the OAuth access token.
        case channelGoalsProgress(broadcasterUserId: String)
        
        /// - broadcasterUserId: The ID of the broadcaster to get notified about. The ID must match the user ID
        ///                      in the OAuth access token.
        case channelGoalsEnd(broadcasterUserId: String)
        
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
        
        /// - clientId: Your application's client id. The provided client ID must match the client id in the
        ///             application access token.
        case userAuthorizationGrant(clientId: String)
        
        /// - clientId: Your application's client ID. The provided client ID must match the client ID in the
        ///             application access token.
        case userAuthorizationRevoke(clientId: String)
        
        /// - userId: The user ID for the user you want update notifications for.
        case userUpdate(userId: String)
        
        /// The type of subscription this condition applies to.
        public var subscriptionType: SubscriptionType {
            switch self {
            case .channelUpdate: return .channelUpdate
            case .channelFollow: return .channelFollow
            case .channelSubscribe: return .channelSubscribe
            case .channelSubscriptionEnd: return .channelSubscriptionEnd
            case .channelSubscriptionGift: return .channelSubscriptionGift
            case .channelSubscriptionMessage: return .channelSubscriptionMessage
            case .channelCheer: return .channelCheer
            case .channelRaid: return .channelRaid
            case .channelBan: return .channelBan
            case .channelUnban: return .channelUnban
            case .channelModeratorAdd: return .channelModeratorAdd
            case .channelModeratorRemove: return .channelModeratorRemove
            case .channelPointsCustomRewardAdd: return .channelPointsCustomRewardAdd
            case .channelPointsCustomRewardUpdate: return .channelPointsCustomRewardUpdate
            case .channelPointsCustomRewardRemove: return .channelPointsCustomRewardRemove
            case .channelPointsCustomRewardRedemptionAdd: return .channelPointsCustomRewardRedemptionAdd
            case .channelPointsCustomRewardRedemptionUpdate: return .channelPointsCustomRewardRedemptionUpdate
            case .channelPollBegin: return .channelPollBegin
            case .channelPollProgress: return .channelPollProgress
            case .channelPollEnd: return .channelPollEnd
            case .channelPredictionBegin: return .channelPredictionBegin
            case .channelPredictionProgress: return .channelPredictionProgress
            case .channelPredictionLock: return .channelPredictionLock
            case .channelPredictionEnd: return .channelPredictionEnd
            case .dropEntitlementGrant: return .dropEntitlementGrant
            case .extensionBitsTransactionCreate: return .extensionBitsTransactionCreate
            case .channelGoalsBegin: return .channelGoalsBegin
            case .channelGoalsProgress: return .channelGoalsProgress
            case .channelGoalsEnd: return .channelGoalsEnd
            case .hypeTrainBegin: return .hypeTrainBegin
            case .hypeTrainProgress: return .hypeTrainProgress
            case .hypeTrainEnd: return .hypeTrainEnd
            case .streamOnline: return .streamOnline
            case .streamOffline: return .streamOffline
            case .userAuthorizationGrant: return .userAuthorizationGrant
            case .userAuthorizationRevoke: return .userAuthorizationRevoke
            case .userUpdate: return .userUpdate
            }
        }
        
        // swiftlint:disable:next cyclomatic_complexity function_body_length
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
            case .channelUpdate:
                self = try .channelUpdate(broadcasterUserId: broadcasterUserId())
            case .channelFollow:
                self = try .channelFollow(broadcasterUserId: broadcasterUserId())
            case .channelSubscribe:
                self = try .channelSubscribe(broadcasterUserId: broadcasterUserId())
            case .channelSubscriptionEnd:
                self = try .channelSubscriptionEnd(broadcasterUserId: broadcasterUserId())
            case .channelSubscriptionGift:
                self = try .channelSubscriptionGift(broadcasterUserId: broadcasterUserId())
            case .channelSubscriptionMessage:
                self = try .channelSubscriptionMessage(broadcasterUserId: broadcasterUserId())
            case .channelCheer:
                self = try .channelCheer(broadcasterUserId: broadcasterUserId())
            case .channelRaid:
                if let broadcasterUserId = try? container.decode(String.self, forKey: .toBroadcasterUserId) {
                    self = .channelRaid(broadcasterUserId: .to(broadcasterUserId: broadcasterUserId))
                } else {
                    let broadcasterUserId = try container.decode(String.self, forKey: .fromBroadcasterUserId)
                    self = .channelRaid(broadcasterUserId: .from(broadcasterUserId: broadcasterUserId))
                }
            case .channelBan:
                self = try .channelBan(broadcasterUserId: broadcasterUserId())
            case .channelUnban:
                self = try .channelUnban(broadcasterUserId: broadcasterUserId())
            case .channelModeratorAdd:
                self = try .channelModeratorAdd(broadcasterUserId: broadcasterUserId())
            case .channelModeratorRemove:
                self = try .channelModeratorRemove(broadcasterUserId: broadcasterUserId())
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
            case .channelPollBegin:
                self = try .channelPollBegin(broadcasterUserId: broadcasterUserId())
            case .channelPollProgress:
                self = try .channelPollProgress(broadcasterUserId: broadcasterUserId())
            case .channelPollEnd:
                self = try .channelPollEnd(broadcasterUserId: broadcasterUserId())
            case .channelPredictionBegin:
                self = try .channelPredictionBegin(broadcasterUserId: broadcasterUserId())
            case .channelPredictionProgress:
                self = try .channelPredictionProgress(broadcasterUserId: broadcasterUserId())
            case .channelPredictionLock:
                self = try .channelPredictionLock(broadcasterUserId: broadcasterUserId())
            case .channelPredictionEnd:
                self = try .channelPredictionEnd(broadcasterUserId: broadcasterUserId())
            case .dropEntitlementGrant:
                let organizationId = try container.decode(String.self, forKey: .organizationId)
                let categoryId = try container.decode(String.self, forKey: .categoryId)
                let campaignId = try container.decode(String.self, forKey: .campaignId)
                self = .dropEntitlementGrant(organizationId: organizationId,
                                             categoryId: categoryId,
                                             campaignId: campaignId)
            case .extensionBitsTransactionCreate:
                let extensionClientId = try container.decode(String.self, forKey: .extensionClientId)
                self = .extensionBitsTransactionCreate(extensionClientId: extensionClientId)
            case .channelGoalsBegin:
                self = try .channelGoalsBegin(broadcasterUserId: broadcasterUserId())
            case .channelGoalsProgress:
                self = try .channelGoalsProgress(broadcasterUserId: broadcasterUserId())
            case .channelGoalsEnd:
                self = try .channelGoalsEnd(broadcasterUserId: broadcasterUserId())
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
            case .userAuthorizationGrant:
                self = try .userAuthorizationGrant(clientId: clientId())
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
                 .channelSubscriptionEnd(let broadcasterUserId),
                 .channelSubscriptionGift(let broadcasterUserId),
                 .channelSubscriptionMessage(let broadcasterUserId),
                 .channelCheer(let broadcasterUserId),
                 .channelBan(let broadcasterUserId),
                 .channelUnban(let broadcasterUserId),
                 .channelModeratorAdd(let broadcasterUserId),
                 .channelModeratorRemove(let broadcasterUserId),
                 .channelPollBegin(let broadcasterUserId),
                 .channelPollProgress(let broadcasterUserId),
                 .channelPollEnd(let broadcasterUserId),
                 .channelPredictionBegin(let broadcasterUserId),
                 .channelPredictionProgress(let broadcasterUserId),
                 .channelPredictionLock(let broadcasterUserId),
                 .channelPredictionEnd(let broadcasterUserId),
                 .channelGoalsBegin(let broadcasterUserId),
                 .channelGoalsProgress(let broadcasterUserId),
                 .channelGoalsEnd(let broadcasterUserId),
                 .hypeTrainBegin(let broadcasterUserId),
                 .hypeTrainProgress(let broadcasterUserId),
                 .hypeTrainEnd(let broadcasterUserId),
                 .streamOnline(let broadcasterUserId),
                 .streamOffline(let broadcasterUserId),
                 .channelPointsCustomRewardAdd(let broadcasterUserId):
                try container.encode(broadcasterUserId, forKey: .broadcasterUserId)
                
            case .channelRaid(let broadcasterUserId):
                switch broadcasterUserId {
                case .to(let broadcasterUserId):
                    try container.encode(broadcasterUserId, forKey: .toBroadcasterUserId)
                case .from(let broadcasterUserId):
                    try container.encode(broadcasterUserId, forKey: .fromBroadcasterUserId)
                }
                
            case .channelPointsCustomRewardUpdate(let broadcasterUserId, let rewardId),
                 .channelPointsCustomRewardRemove(let broadcasterUserId, let rewardId),
                 .channelPointsCustomRewardRedemptionAdd(let broadcasterUserId, let rewardId),
                 .channelPointsCustomRewardRedemptionUpdate(let broadcasterUserId, let rewardId):
                try container.encode(broadcasterUserId, forKey: .broadcasterUserId)
                try container.encodeIfPresent(rewardId, forKey: .rewardId)
                
            case .dropEntitlementGrant(let organizationId,
                                       let categoryId,
                                       let campaignId):
                try container.encode(organizationId, forKey: .organizationId)
                try container.encodeIfPresent(categoryId, forKey: .categoryId)
                try container.encode(campaignId, forKey: .campaignId)
                
            case .extensionBitsTransactionCreate(let extensionClientId):
                try container.encode(extensionClientId, forKey: .extensionClientId)
                
            case .userAuthorizationGrant(let clientId),
                 .userAuthorizationRevoke(let clientId):
                try container.encode(clientId, forKey: .clientId)
                
            case .userUpdate(let userId):
                try container.encode(userId, forKey: .userId)
            }
        }
        
        internal enum CodingKeys: String, CodingKey {
            case broadcasterUserId
            case fromBroadcasterUserId
            case toBroadcasterUserId
            case rewardId
            case clientId
            case userId
            case organizationId
            case categoryId
            case campaignId
            case extensionClientId
        }
    }
}
