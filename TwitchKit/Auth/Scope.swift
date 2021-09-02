//
//  Scope.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// A permission that your app requires.
public enum Scope: String, Codable, CaseIterable, CustomStringConvertible {
    
    /// View analytics data for the Twitch Extensions owned by the authenticated account.
    case analyticsReadExtensions = "analytics:read:extensions"
    
    /// View analytics data for the games owned by the authenticated account.
    case analyticsReadGames = "analytics:read:games"
    
    /// View Bits information for a channel.
    case bitsRead = "bits:read"
    
    /// Run commercials on a channel.
    case channelEditCommercial = "channel:edit:commercial"
    
    /// Manage a channel’s broadcast configuration, including updating channel configuration and managing stream
    /// markers and stream tags.
    case channelManageBroadcast = "channel:manage:broadcast"
    
    /// Manage a channel’s Extension configuration, including activating Extensions.
    case channelManageExtensions = "channel:manage:extensions"
    
    /// Manage a channel’s polls.
    case channelManagePolls = "channel:manage:polls"
    
    /// Manage a channel's Channel Points Predictions
    case channelManagePredictions = "channel:manage:predictions"
    
    /// Manage Channel Points custom rewards and their redemptions on a channel.
    case channelManageRedemptions = "channel:manage:redemptions"
    
    /// Manage a channel's stream schedule.
    case channelManageSchedule = "channel:manage:schedule"
    
    /// Manage a channel’s videos, including deleting videos.
    case channelManageVideos = "channel:manage:videos"
    
    /// View a list of users with the editor role for a channel.
    case channelReadEditors = "channel:read:editors"
    
    /// View Creator Goals for a channel.
    case channelReadGoals = "channel:read:goals"
    
    /// View Hype Train information for a channel.
    case channelReadHypeTrain = "channel:read:hype_train"
    
    /// View a channel's polls.
    case channelReadPolls = "channel:read:polls"
    
    /// View a channel’s Channel Points Predictions.
    case channelReadPredictions = "channel:read:predictions"
    
    /// View Channel Points custom rewards and their redemptions on a channel.
    case channelReadRedemptions = "channel:read:redemptions"
    
    /// Read an authorized user’s stream key.
    case channelReadStreamKey = "channel:read:stream_key"
    
    /// View a list of all subscribers to a channel and check if a user is subscribed to a channel.
    case channelReadSubscriptions = "channel:read:subscriptions"
    
    /// Manage Clips for a channel.
    case clipsEdit = "clips:edit"
    
    /// View a channel's moderation data including Moderators, Bans, Timeouts, and AutoMod settings.
    case moderationRead = "moderation:read"
    
    /// Manage messages held for review by AutoMod in channels where you are a moderator.
    case moderatorManageAutoMod = "moderator:manage:automod"
    
    /// Manage a user object.
    case userEdit = "user:edit"
    
    /// Deprecated. Was previously used for "Create User Follows" and "Delete User Follows."
    case userEditFollows = "user:edit:follows"
    
    /// Manage the block list of a user.
    case userManageBlockedUsers = "user:manage:blocked_users"
    
    /// View the block list of a user.
    case userReadBlockedUsers = "user:read:blocked_users"
    
    /// Edit a channel's broadcast configuration, including extension configuration.
    /// (This scope implies `.userReadBroadcast` capability.)
    case userEditBroadcast = "user:edit:broadcast"
    
    /// View a user's broadcasting configuration, including Extension configurations.
    case userReadBroadcast = "user:read:broadcast"
    
    /// View a user's email address.
    case userReadEmail = "user:read:email"
    
    /// View the list of channels a user follows.
    case userReadFollows = "user:read:follows"
    
    /// View if an authorized user is subscribed to specific channels.
    case userReadSubscriptions = "user:read:subscriptions"
    
    // MARK: - Legacy Twitch API v5 Scopes
    
    /// Legacy Twitch API v5 scope. Read all subscribers to a channel.
    case channelSubscriptions = "channel_subscriptions"
    
    /// Legacy Twitch API v5 scope. Trigger commercials on a channel.
    case channelCommercial = "channel_commercial"
    
    /// Legacy Twitch API v5 scope. Write channel metadata (game, status, etc).
    case channelEditor = "channel_editor"
    
    /// Legacy Twitch API v5 scope. Manage a user’s followed channels.
    case userFollowsEdit = "user_follows_edit"
    
    /// Legacy Twitch API v5 scope. View a channel’s email address and stream key.
    case channelRead = "channel_read"
    
    /// Legacy Twitch API v5 scope. View a user’s information.
    case userRead = "user_read"
    
    /// Legacy Twitch API v5 scope. Read a user’s block list.
    case userBlocksRead = "user_blocks_read"
    
    /// Legacy Twitch API v5 scope. Manage a user’s block list.
    case userBlocksEdit = "user_blocks_edit"
    
    /// Legacy Twitch API v5 scope. Perform moderation actions in a channel. The user requesting the scope must be a
    /// moderator in the channel.
    case channelModerate = "channel:moderate"
    
    /// Legacy Twitch API v5 scope. Send live stream chat and rooms messages.
    case chatEdit = "chat:edit"
    
    /// Legacy Twitch API v5 scope. View live stream chat and rooms messages.
    case chatRead = "chat:read"
    
    /// Legacy Twitch API v5 scope. View your whisper messages.
    case whispersRead = "whispers:read"
    
    /// Legacy Twitch API v5 scope. Send whisper messages.
    case whispersEdit = "whispers:edit"
    
    // MARK: - Internal Scopes
    
    /// The scope that all OIDC authorization requests must include.
    ///
    /// There is no need for you to use this scope, as it is only used internally by the SDK.
    /// It is automatically included for you when you use an OIDC authorization flow and
    /// excluded if you use OAuth authorization.
    case openId = "openid"
    
    public var description: String { rawValue }
}

extension Set where Element == Scope {
    
    /// All scopes.
    public static let all = Set(Scope.allCases)
}
