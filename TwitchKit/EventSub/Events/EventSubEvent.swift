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
        case channelCheer(ChannelCheer)
        
        /// <#Description#>
        case channelBan(ChannelBan)
        
        /// <#Description#>
        case channelUnban(ChannelUnban)
        
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
        case userAuthorizationRevoke(UserAuthorizationRevoke)
        
        /// <#Description#>
        case userUpdate(UserUpdate)
        
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
            case .channelCheer:
                self = try .channelCheer(event())
            case .channelBan:
                self = try .channelBan(event())
            case .channelUnban:
                self = try .channelUnban(event())
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
            case .userAuthorizationRevoke:
                self = try .userAuthorizationRevoke(event())
            case .userUpdate:
                self = try .userUpdate(event())
            }
        }
    }
}
