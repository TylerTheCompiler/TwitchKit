//
//  EventSubSubscriptionType.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub {
    
    /// The type of EventSub subscription.
    public enum SubscriptionType: String, Codable {
        
        /// A broadcaster updates their channel properties e.g., category, title, mature flag, broadcast, or language.
        case channelUpdate = "channel.update"
        
        /// A specified channel receives a follow.
        case channelFollow = "channel.follow"
        
        /// A notification when a specified channel receives a subscriber. This does not include resubscribes.
        case channelSubscribe = "channel.subscribe"
        
        /// A user cheers on the specified channel.
        case channelCheer = "channel.cheer"
        
        /// A viewer is banned from the specified channel.
        case channelBan = "channel.ban"
        
        /// A viewer is unbanned from the specified channel.
        case channelUnban = "channel.unban"
        
        /// A custom channel points reward has been created for the specified channel.
        case channelPointsCustomRewardAdd = "channel.channel_points_custom_reward.add"
        
        /// A custom channel points reward has been updated for the specified channel.
        case channelPointsCustomRewardUpdate = "channel.channel_points_custom_reward.update"
        
        /// A custom channel points reward has been removed from the specified channel.
        case channelPointsCustomRewardRemove = "channel.channel_points_custom_reward.remove"
        
        /// A viewer has redeemed a custom channel points reward on the specified channel.
        case channelPointsCustomRewardRedemptionAdd = "channel.channel_points_custom_reward_redemption.add"
        
        /// A redemption of a channel points custom reward has been updated for the specified channel.
        case channelPointsCustomRewardRedemptionUpdate = "channel.channel_points_custom_reward_redemption.update"
        
        /// A hype train begins on the specified channel.
        case hypeTrainBegin = "channel.hype_train.begin"
        
        /// A hype train makes progress on the specified channel.
        case hypeTrainProgress = "channel.hype_train.progress"
        
        /// A hype train ends on the specified channel.
        case hypeTrainEnd = "channel.hype_train.end"
        
        /// The specified broadcaster starts a stream.
        case streamOnline = "stream.online"
        
        /// The specified broadcaster stops a stream.
        case streamOffline = "stream.offline"
        
        /// A user has revoked authorization for your client id.
        case userAuthorizationRevoke = "user.authorization.revoke"
        
        /// A user has updated their account.
        case userUpdate = "user.update"
    }
}
