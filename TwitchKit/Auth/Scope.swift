//
//  Scope.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// A permission that your app requires.
public enum Scope: String, Codable, CaseIterable, CustomStringConvertible {
    
    /// View analytics data for your extensions.
    case analyticsReadExtensions = "analytics:read:extensions"
    
    /// View analytics data for your games.
    case analyticsReadGames = "analytics:read:games"
    
    /// View Bits information for your channel.
    case bitsRead = "bits:read"
    
    /// Run commercials on a channel.
    case channelEditCommercial = "channel:edit:commercial"
    
    /// Manage your channel’s broadcast configuration, including updating channel configuration and managing stream
    /// markers and stream tags.
    case channelManageBroadcast = "channel:manage:broadcast"
    
    /// Manage your channel’s extension configuration, including activating extensions.
    case channelManageExtensions = "channel:manage:extensions"
    
    /// Gets the most recent hype train on a channel.
    case channelReadHypeTrain = "channel:read:hype_train"
    
    /// Manage Channel Points custom rewards and their redemptions on a channel.
    case channelManageRedemptions = "channel:manage:redemptions"
    
    /// View Channel Points custom rewards and their redemptions on a channel.
    case channelReadRedemptions = "channel:read:redemptions"
    
    /// Read an authorized user’s stream key.
    case channelReadStreamKey = "channel:read:stream_key"
    
    /// Get a list of all subscribers to your channel and check if a user is subscribed to your channel.
    case channelReadSubscriptions = "channel:read:subscriptions"
    
    /// Perform moderation actions in a channel. The user requesting the scope must be a moderator in the channel.
    case channelModerate = "channel:moderate"
    
    /// Send live stream chat and rooms messages.
    case chatEdit = "chat:edit"
    
    /// View live stream chat and rooms messages.
    case chatRead = "chat:read"
    
    /// Manage a clip object.
    case clipsEdit = "clips:edit"
    
    /// Get banned/timed-out users, ban/unban events, list of moderators, moderator actions, and check AutoMod status.
    case moderationRead = "moderation:read"
    
    /// Manage a user object.
    case userEdit = "user:edit"
    
    /// Edit your follows.
    case userEditFollows = "user:edit:follows"
    
    /// Edit your channel's broadcast configuration, including extension configuration.
    /// (This scope implies `.userReadBroadcast` capability.)
    case userEditBroadcast = "user:edit:broadcast"
    
    /// View your broadcasting configuration, including extension configurations.
    case userReadBroadcast = "user:read:broadcast"
    
    /// Read an authorized user’s email address.
    case userReadEmail = "user:read:email"
    
    /// Send whisper messages.
    case whispersEdit = "whispers:edit"
    
    /// View your whisper messages.
    case whispersRead = "whispers:read"
    
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
