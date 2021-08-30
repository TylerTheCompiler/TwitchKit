//
//  PubSubTopic.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub {
    
    /// A PubSub topic that can be listened to by a `PubSub.Connection`.
    public enum Topic: RawRepresentable, Hashable, Codable {
        
        /// A topic that fires events when someone cheers in a channel. (Version 1)
        ///
        /// `channelId` is the channel in which to listen for cheers.
        ///
        /// - Note: You probably want to listen to the newer `bitsV2` topic, not this one.
        case bitsV1(channelId: String)
        
        /// A topic that fires events when someone cheers in a channel. (Version 2)
        ///
        /// `channelId` is the channel in which to listen for cheers.
        case bitsV2(channelId: String)
        
        /// A topic that fires events when someone unlocks a new Bits badge by cheering in a channel.
        ///
        /// `channelId` is the channel in which to listen for Bits badge unlocks.
        case bitsBadgeUnlocks(channelId: String)
        
        /// A topic that fires events related to a channel's Channel Points, such as when a user redeems a reward
        /// or when a custom reward is created or deleted.
        ///
        /// `channelId` is the channel in which to listen for Channel Points events.
        case channelPoints(channelId: String)
        
        /// A topic that fires events when a user subscribes to a channel.
        ///
        /// `channelId` is the channel in which to listen for subscriptions.
        case channelSubscriptions(channelId: String)
        
        /// A topic that fires events related to moderation in a channel, such as when a user is banned or timed out.
        ///
        /// `userId` is the user who owns the channel.
        /// `channelId` is the channel in which to listen for moderation events.
        case moderatorActions(userId: String, channelId: String)
        
        /// A topic that fires events when AutoMod flags a message as potentially inappropriate, and when a
        /// moderator takes action on a message.
        ///
        /// `moderatorId` is the ID of the moderator to listen for.
        /// `channelId` is the channel in which to listen for moderation events.
        case autoModQueue(moderatorId: String, channelId: String)
        
        /// A user's message held by AutoMod has been approved or denied.
        ///
        /// `userId` is the ID of the user to listen for.
        /// `channelId` is the channel in which to listen for moderation events.
        case userModerationNotifications(userId: String, channelId: String)
        
        /// A topic that fires events related to private messages (a.k.a. "whispers").
        ///
        /// `userId` is the user whose whisper events you want to listen to.
        case whispers(userId: String)
        
        public var rawValue: String {
            switch self {
            case .bitsV1(let channelId):
                return "channel-bits-events-v1.\(channelId)"
            case .bitsV2(let channelId):
                return "channel-bits-events-v2.\(channelId)"
            case .bitsBadgeUnlocks(let channelId):
                return "channel-bits-badge-unlocks.\(channelId)"
            case .channelPoints(let channelId):
                return "channel-points-channel-v1.\(channelId)"
            case .channelSubscriptions(let channelId):
                return "channel-subscribe-events-v1.\(channelId)"
            case .moderatorActions(let userId, let channelId):
                return "chat_moderator_actions.\(userId).\(channelId)"
            case .autoModQueue(let moderatorId, let channelId):
                return "automod-queue.\(moderatorId).\(channelId)"
            case .userModerationNotifications(let userId, let channelId):
                return "user-moderation-notifications.\(userId).\(channelId)"
            case .whispers(let userId):
                return "whispers.\(userId)"
            }
        }
        
        public var channelId: String? {
            switch self {
            case .bitsV1(let channelId),
                 .bitsV2(let channelId),
                 .bitsBadgeUnlocks(let channelId),
                 .channelPoints(let channelId),
                 .channelSubscriptions(let channelId),
                 .moderatorActions(_, let channelId),
                 .autoModQueue(_, let channelId),
                 .userModerationNotifications(_, let channelId):
                return channelId
            case .whispers:
                return nil
            }
        }
        
        public init?(rawValue: String) {
            let components = rawValue.components(separatedBy: ".")
            guard components.count >= 2 else { return nil }
            let firstComponent = components[0]
            let secondComponent = components[1]
            switch firstComponent {
            case "channel-bits-events-v1":
                self = .bitsV1(channelId: secondComponent)
                
            case "channel-bits-events-v2":
                self = .bitsV2(channelId: secondComponent)
                
            case "channel-bits-badge-unlocks":
                self = .bitsBadgeUnlocks(channelId: secondComponent)
                
            case "channel-points-channel-v1":
                self = .channelPoints(channelId: secondComponent)
                
            case "channel-subscribe-events-v1":
                self = .channelSubscriptions(channelId: secondComponent)
                
            case "chat_moderator_actions":
                guard components.count >= 3 else { return nil }
                let thirdComponent = components[2]
                self = .moderatorActions(userId: secondComponent, channelId: thirdComponent)
                
            case "automod-queue":
                guard components.count >= 3 else { return nil }
                let thirdComponent = components[2]
                self = .autoModQueue(moderatorId: secondComponent, channelId: thirdComponent)
                
            case "user-moderation-notifications":
                guard components.count >= 3 else { return nil }
                let thirdComponent = components[2]
                self = .userModerationNotifications(userId: secondComponent, channelId: thirdComponent)
                
            case "whispers":
                self = .whispers(userId: secondComponent)
                
            default:
                return nil
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            guard let topic = Topic(rawValue: rawValue) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid raw value")
            }
            
            self = topic
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }
}
