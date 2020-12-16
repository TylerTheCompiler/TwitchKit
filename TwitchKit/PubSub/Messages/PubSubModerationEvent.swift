//
//  PubSubModerationEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub.Message {
    
    /// A PubSub event received when a moderator action occurs, such as bans, unbans, timeouts, deleting messages,
    /// changing chat mode (followers-only, subs-only), changing AutoMod levels, and adding a mod.
    ///
    /// Supports moderators listening to the topic, as well as users listening to the topic to receive their own
    /// events.
    public struct ModerationEvent: Decodable {
        
        /// Describes the category of a moderator action.
        public enum ActionType: String, Decodable {
            
            /// The action was related to a user login.
            case chatLoginModeration = "chat_login_moderation"
            
            /// The action was related to a channel.
            case chatChannelModeration = "chat_channel_moderation"
        }
        
        /// Describes an action that a moderator took in a channel.
        public enum Action: RawRepresentable, Decodable {
            
            /// A user was timed out.
            case timeout
            
            /// A user was un-timed out.
            case untimeout
            
            /// A user was banned.
            case ban
            
            /// A user was unbanned.
            case unban
            
            /// The chatroom was cleared.
            case clear
            
            /// The chatroom was put into slow mode.
            case slow
            
            /// Slow mode was turned off.
            case slowOff
            
            /// The chatroom was put into emote-only mode.
            case emoteOnly
            
            /// Emote-only mode was turned off.
            case emoteOnlyOff
            
            /// The chatroom was put into followers-only mode.
            case followersOnly
            
            /// Followers-only mode was turned off.
            case followersOnlyOff
            
            /// The chatroom was put into subscribers-only mode.
            case subscribersOnly
            
            /// Subscribers-only mode was turned off.
            case subscribersOnlyOff
            
            /// The chatroom was put into unique mode (aka R9K mode).
            case uniqueChat
            
            /// Unique mode was turned off.
            case uniqueChatOff
            
            /// Some other unknown moderator action took place.
            case other(String)
            
            public var rawValue: String {
                switch self {
                case .timeout: return "timeout"
                case .untimeout: return "untimeout"
                case .ban: return "ban"
                case .unban: return "unban"
                case .clear: return "clear"
                case .slow: return "slow"
                case .slowOff: return "slowoff"
                case .emoteOnly: return "emoteonly"
                case .emoteOnlyOff: return "emoteonlyoff"
                case .followersOnly: return "followers"
                case .followersOnlyOff: return "followersoff"
                case .subscribersOnly: return "subscribers"
                case .subscribersOnlyOff: return "subscribersoff"
                case .uniqueChat: return "r9kbeta"
                case .uniqueChatOff: return "r9kbetaoff"
                case .other(let rawValue): return rawValue
                }
            }
            
            public init(rawValue: String) {
                switch rawValue {
                case Self.timeout.rawValue: self = .timeout
                case Self.untimeout.rawValue: self = .untimeout
                case Self.ban.rawValue: self = .ban
                case Self.unban.rawValue: self = .unban
                case Self.clear.rawValue: self = .clear
                case Self.slow.rawValue: self = .slow
                case Self.slowOff.rawValue: self = .slowOff
                case Self.emoteOnly.rawValue: self = .emoteOnly
                case Self.emoteOnlyOff.rawValue: self = .emoteOnlyOff
                case Self.followersOnly.rawValue: self = .followersOnly
                case Self.followersOnlyOff.rawValue: self = .followersOnlyOff
                case Self.subscribersOnly.rawValue: self = .subscribersOnly
                case Self.subscribersOnlyOff.rawValue: self = .subscribersOnlyOff
                case Self.uniqueChat.rawValue: self = .uniqueChat
                case Self.uniqueChatOff.rawValue: self = .uniqueChatOff
                default: self = .other(rawValue)
                }
            }
        }
        
        /// Additional `ModerationEvent` info.
        public struct Data: Decodable {
            
            /// The type/category of moderation action.
            public let type: ActionType
            
            /// The moderation action.
            public let moderationAction: Action
            
            /// The arguments (if any) that were passed to the moderation command.
            public let args: [String]
            
            /// The login of the user who performed the moderation action.
            public let createdBy: String
            
            /// The user ID of the user who performed the moderation action.
            public let createdByUserId: String
            
            /// The ID of the message.
            public let msgId: String
            
            /// The user ID of the user that was moderated.
            public let targetUserId: String
            
            /// The login of the user that was moderated.
            public let targetUserLogin: String
            
            /// Whether the event was due to AutoMod or not.
            public let fromAutomod: Bool
        }
        
        /// The type of message.
        public let type: String
        
        /// Additional event info.
        public let data: Data
    }
}
