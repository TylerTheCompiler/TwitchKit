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
        
        /// A notification when a subscription to the specified channel ends.
        case channelSubscriptionEnd = "channel.subscription.end"
        
        /// A notification when a viewer gives a gift subscription to one or more users in the specified channel.
        case channelSubscriptionGift = "channel.subscription.gift"
        
        /// A notification when a user sends a resubscription chat message in a specific channel.
        case channelSubscriptionMessage = "channel.subscription.message"
        
        /// A user cheers on the specified channel.
        case channelCheer = "channel.cheer"
        
        /// A broadcaster raids another broadcaster's channel.
        case channelRaid = "channel.raid"
        
        /// A viewer is banned from the specified channel.
        case channelBan = "channel.ban"
        
        /// A viewer is unbanned from the specified channel.
        case channelUnban = "channel.unban"
        
        /// Moderator privileges were added to a user on a specified channel.
        case channelModeratorAdd = "channel.moderator.add"
        
        /// Moderator privileges were removed from a user on a specified channel.
        case channelModeratorRemove = "channel.moderator.remove"
        
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
        
        /// A poll started on a specified channel.
        case channelPollBegin = "channel.poll.begin"
        
        /// Users respond to a poll on a specified channel.
        case channelPollProgress = "channel.poll.progress"
        
        /// A poll ended on a specified channel.
        case channelPollEnd = "channel.poll.end"
        
        /// A Prediction started on a specified channel.
        case channelPredictionBegin = "channel.prediction.begin"
        
        /// Users participated in a Prediction on a specified channel.
        case channelPredictionProgress = "channel.prediction.progress"
        
        /// A Prediction was locked on a specified channel.
        case channelPredictionLock = "channel.prediction.lock"
        
        /// A Prediction ended on a specified channel.
        case channelPredictionEnd = "channel.prediction.end"
        
        /// An entitlement for a Drop is granted to a user.
        case dropEntitlementGrant = "drop.entitlement.grant"
        
        /// A Bits transaction occurred for a specified Twitch Extension.
        case extensionBitsTransactionCreate = "extension.bits_transaction.create"
        
        /// Get notified when a broadcaster begins a goal.
        case channelGoalsBegin = "channel.goals.begin"
        
        /// Get notified when progress (either positive or negative) is made towards a broadcaster's goal.
        case channelGoalsProgress = "channel.goals.progress"
        
        /// Get notified when a broadcaster ends a goal.
        case channelGoalsEnd = "channel.goals.end"
        
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
        
        /// A user's authorization has been granted to your client id.
        case userAuthorizationGrant = "user.authorization.grant"
        
        /// A user has revoked authorization for your client id.
        case userAuthorizationRevoke = "user.authorization.revoke"
        
        /// A user has updated their account.
        case userUpdate = "user.update"
        
        var isBatchingEnabled: Bool {
            switch self {
            case .dropEntitlementGrant:
                return true
            default:
                return false
            }
        }
    }
}
