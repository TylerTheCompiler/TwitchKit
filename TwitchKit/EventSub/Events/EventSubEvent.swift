//
//  EventSubEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub {
    
    /// <#Description#>
    public enum Event {
        
        /// <#Description#>
        case channelUpdate(ChannelUpdate)
        
        /// <#Description#>
        case channelFollow(ChannelFollow)
        
        /// <#Description#>
        case channelSubscribe(ChannelSubscribe)
        
        /// <#Description#>
        case channelSubscriptionEnd(ChannelSubscriptionEnd)
        
        /// <#Description#>
        case channelSubscriptionGift(ChannelSubscriptionGift)
        
        /// <#Description#>
        case channelSubscriptionMessage(ChannelSubscriptionMessage)
        
        /// <#Description#>
        case channelCheer(ChannelCheer)
        
        /// <#Description#>
        case channelRaid(ChannelRaid)
        
        /// <#Description#>
        case channelBan(ChannelBan)
        
        /// <#Description#>
        case channelUnban(ChannelUnban)
        
        /// <#Description#>
        case channelModeratorAdd(ChannelModeratorAdd)
        
        /// <#Description#>
        case channelModeratorRemove(ChannelModeratorRemove)
        
        /// <#Description#>
        case channelPointsCustomRewardAdd(ChannelPointsCustomReward)
        
        /// <#Description#>
        case channelPointsCustomRewardUpdate(ChannelPointsCustomReward)
        
        /// <#Description#>
        case channelPointsCustomRewardRemove(ChannelPointsCustomReward)
        
        /// <#Description#>
        case channelPointsCustomRewardRedemptionAdd(ChannelPointsCustomRewardRedemption)
        
        /// <#Description#>
        case channelPointsCustomRewardRedemptionUpdate(ChannelPointsCustomRewardRedemption)
        
        /// <#Description#>
        case channelPollBegin(ChannelPollBegin)
        
        /// <#Description#>
        case channelPollProgress(ChannelPollProgress)
        
        /// <#Description#>
        case channelPollEnd(ChannelPollEnd)
        
        /// <#Description#>
        case channelPredictionBegin(ChannelPredictionBegin)
        
        /// <#Description#>
        case channelPredictionProgress(ChannelPredictionProgress)
        
        /// <#Description#>
        case channelPredictionLock(ChannelPredictionLock)
        
        /// <#Description#>
        case channelPredictionEnd(ChannelPredictionEnd)
        
        /// <#Description#>
        case dropEntitlementGrant(DropEntitlementGrant)
        
        /// <#Description#>
        case extensionBitsTransactionCreate(ExtensionBitsTransactionCreate)
        
        /// <#Description#>
        case channelGoalsBegin(ChannelGoalsBegin)
        
        /// <#Description#>
        case channelGoalsProgress(ChannelGoalsProgress)
        
        /// <#Description#>
        case channelGoalsEnd(ChannelGoalsEnd)
        
        /// <#Description#>
        case hypeTrainBegin(HypeTrainBegin)
        
        /// <#Description#>
        case hypeTrainProgress(HypeTrainProgress)
        
        /// <#Description#>
        case hypeTrainEnd(HypeTrainEnd)
        
        /// <#Description#>
        case streamOnline(StreamOnline)
        
        /// <#Description#>
        case streamOffline(StreamOffline)
        
        /// <#Description#>
        case userAuthorizationGrant(UserAuthorizationGrant)
        
        /// <#Description#>
        case userAuthorizationRevoke(UserAuthorizationRevoke)
        
        /// <#Description#>
        case userUpdate(UserUpdate)
        
        // swiftlint:disable:next cyclomatic_complexity function_body_length
        internal init(container: KeyedDecodingContainer<Notification.CodingKeys>,
                      subscriptionType: SubscriptionType) throws {
            func event<EventType: Decodable>(_ type: EventType.Type = EventType.self) throws -> EventType {
                try container.decode(type, forKey: .event)
            }
            
            switch subscriptionType {
            case .channelUpdate:
                self = try .channelUpdate(event())
            case .channelFollow:
                self = try .channelFollow(event())
            case .channelSubscribe:
                self = try .channelSubscribe(event())
            case .channelSubscriptionEnd:
                self = try .channelSubscriptionEnd(event())
            case .channelSubscriptionGift:
                self = try .channelSubscriptionGift(event())
            case .channelSubscriptionMessage:
                self = try .channelSubscriptionMessage(event())
            case .channelCheer:
                self = try .channelCheer(event())
            case .channelRaid:
                self = try .channelRaid(event())
            case .channelBan:
                self = try .channelBan(event())
            case .channelUnban:
                self = try .channelUnban(event())
            case .channelModeratorAdd:
                self = try .channelModeratorAdd(event())
            case .channelModeratorRemove:
                self = try .channelModeratorRemove(event())
            case .channelPointsCustomRewardAdd:
                self = try .channelPointsCustomRewardAdd(event())
            case .channelPointsCustomRewardUpdate:
                self = try .channelPointsCustomRewardUpdate(event())
            case .channelPointsCustomRewardRemove:
                self = try .channelPointsCustomRewardRemove(event())
            case .channelPointsCustomRewardRedemptionAdd:
                self = try .channelPointsCustomRewardRedemptionAdd(event())
            case .channelPointsCustomRewardRedemptionUpdate:
                self = try .channelPointsCustomRewardRedemptionUpdate(event())
            case .channelPollBegin:
                self = try .channelPollBegin(event())
            case .channelPollProgress:
                self = try .channelPollProgress(event())
            case .channelPollEnd:
                self = try .channelPollEnd(event())
            case .channelPredictionBegin:
                self = try .channelPredictionBegin(event())
            case .channelPredictionProgress:
                self = try .channelPredictionProgress(event())
            case .channelPredictionLock:
                self = try .channelPredictionLock(event())
            case .channelPredictionEnd:
                self = try .channelPredictionEnd(event())
            case .dropEntitlementGrant:
                self = try .dropEntitlementGrant(event())
            case .extensionBitsTransactionCreate:
                self = try .extensionBitsTransactionCreate(event())
            case .channelGoalsBegin:
                self = try .channelGoalsBegin(event())
            case .channelGoalsProgress:
                self = try .channelGoalsProgress(event())
            case .channelGoalsEnd:
                self = try .channelGoalsEnd(event())
            case .hypeTrainBegin:
                self = try .hypeTrainBegin(event())
            case .hypeTrainProgress:
                self = try .hypeTrainProgress(event())
            case .hypeTrainEnd:
                self = try .hypeTrainEnd(event())
            case .streamOnline:
                self = try .streamOnline(event())
            case .streamOffline:
                self = try .streamOffline(event())
            case .userAuthorizationGrant:
                self = try .userAuthorizationGrant(event())
            case .userAuthorizationRevoke:
                self = try .userAuthorizationRevoke(event())
            case .userUpdate:
                self = try .userUpdate(event())
            }
        }
    }
}
