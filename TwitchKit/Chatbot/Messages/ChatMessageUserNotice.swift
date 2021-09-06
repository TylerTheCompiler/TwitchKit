//
//  ChatMessageUserNotice.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// Sends a notice to the user when various events occur.
    ///
    /// Sends a notice to the user when any of the following events occurs:
    ///
    /// - Subscription, resubscription, or gift subscription to a channel.
    ///
    /// - Incoming raid to a channel. Raid is a Twitch tool that allows broadcasters to send their viewers to
    ///   another channel, to help support and grow other members in the community.
    ///
    /// - Channel ritual. Many channels have special rituals to celebrate viewer milestones when they are shared.
    ///   The rituals notice extends the sharing of these messages to other viewer milestones, for example, a new
    ///   viewer chatting for the first time.
    public struct UserNotice {
        
        /// Contains additional information about a `UserNotice` message.
        public enum UserNoticeType {
            
            /// The type of subscription plan being used.
            public enum SubPlan: String {
                
                /// Prime Gaming plan.
                case prime = "Prime"
                
                /// Tier one sub plan.
                case tier1 = "1000"
                
                /// Tier two sub plan.
                case tier2 = "2000"
                
                /// Tier three sub plan.
                case tier3 = "3000"
                
                /// An unknown sub plan type.
                case unknown
                
                public init(rawValue: String) {
                    switch rawValue {
                    case Self.prime.rawValue: self = .prime
                    case Self.tier1.rawValue: self = .tier1
                    case Self.tier2.rawValue: self = .tier2
                    case Self.tier3.rawValue: self = .tier3
                    default: self = .unknown
                    }
                }
            }
            
            /// Information about a user's subscription to a channel.
            public struct SubInfo {
                
                /// The total number of months the user has subscribed.
                public let cumulativeMonths: Int
                
                /// Indicates whether users want their streaks to be shared.
                public let shouldShareStreak: Bool
                
                /// The number of consecutive months the user has subscribed. This is 0 if `shouldShareStreak` is 0.
                public let streakMonths: Int
                
                /// The type of subscription plan being used.
                public let subPlan: SubPlan
                
                /// The display name of the subscription plan. This may be a default name or one created by
                /// the channel owner.
                public let subPlanName: String
            }
            
            /// Information about a gifted subscription to a channel.
            public struct GiftSubInfo {
                
                /// Information about the recipient of the gift sub.
                public struct Recipient {
                    
                    /// The user ID of the subscription gift recipient.
                    public let id: String
                    
                    /// The display name of the subscription gift recipient.
                    public let displayName: String
                    
                    /// The username of the subscription gift recipient.
                    public let username: String
                }
                
                public let months: Int
                
                /// Information about the recipient of the gift sub.
                public let recipient: Recipient
                
                /// The type of subscription plan being used.
                public let subPlan: SubPlan
                
                /// The display name of the subscription plan. This may be a default name or one created by
                /// the channel owner.
                public let subPlanName: String
                
                /// Number of months gifted as part of a single, multi-month gift.
                public let giftMonths: Int
            }
            
            /// Information about a gift paid upgrade.
            public struct GiftPaidUpgradeInfo {
                
                /// The number of gifts the gifter has given during the promo indicated by `promoName`.
                public let promoGiftTotal: Int
                
                /// The subscription's promo, if any, that is ongoing; e.g. Subtember 2018.
                public let promoName: String
                
                /// The login of the user who gifted the subscription.
                public let senderLogin: String
                
                /// The display name of the user who gifted the subscription.
                public let senderName: String
            }
            
            /// Information about an anonymous gift paid upgrade.
            public struct AnonGiftPaidUpgradeInfo {
                
                /// The number of gifts the gifter has given during the promo indicated by `promoName`.
                public let promoGiftTotal: Int
                
                /// The subscription's promo, if any, that is ongoing; e.g. Subtember 2018.
                public let promoName: String
            }
            
            // Information about a raid to a channel.
            public struct RaidInfo {
                
                /// The display name of the source user raiding this channel.
                public let displayName: String
                
                /// The name of the source user raiding this channel.
                public let login: String
                
                /// The number of viewers watching the source channel raiding this channel.
                public let viewerCount: Int
            }
            
            case sub(SubInfo)
            case resub(SubInfo)
            case subGift(GiftSubInfo)
            case anonSubGift(GiftSubInfo)
            case subMysteryGift
            case giftPaidUpgrade(GiftPaidUpgradeInfo)
            case rewardGift
            case anonGiftPaidUpgrade(AnonGiftPaidUpgradeInfo)
            case raid(RaidInfo)
            case unraid
            case ritual(name: String)
            case bitsBadgeTier(threshold: Int)
            case unknown(params: [String: String])
            
            internal init(dictionary: [String: String]) {
                let type = dictionary["msg-id"]
                switch type {
                case "sub", "resub":
                    let subInfo = SubInfo(
                        cumulativeMonths: dictionary["msg-param-cumulative-months"].flatMap { Int($0) } ?? 0,
                        shouldShareStreak: dictionary["msg-param-should-share-streak"] == "true",
                        streakMonths: dictionary["msg-param-streak-months"].flatMap { Int($0) } ?? 0,
                        subPlan: dictionary["msg-param-sub-plan"].map { SubPlan(rawValue: $0) } ?? .unknown,
                        subPlanName: dictionary["msg-param-sub-plan-name"] ?? ""
                    )
                    
                    if type == "sub" {
                        self = .sub(subInfo)
                    } else {
                        self = .resub(subInfo)
                    }
                    
                case "subgift", "anonsubgift":
                    let giftSubInfo = GiftSubInfo(
                        months: dictionary["msg-param-months"].flatMap { Int($0) } ?? 0,
                        recipient: .init(
                            id: dictionary["msg-param-recipient-id"] ?? "",
                            displayName: dictionary["msg-param-recipient-display-name"] ?? "",
                            username: dictionary["msg-param-recipient-user-name"] ?? ""
                        ),
                        subPlan: dictionary["msg-param-sub-plan"].map { SubPlan(rawValue: $0) } ?? .unknown,
                        subPlanName: dictionary["msg-param-sub-plan-name"] ?? "",
                        giftMonths: dictionary["msg-param-gift-months"].flatMap { Int($0) } ?? 0
                    )
                    
                    if type == "subgift" {
                        self = .subGift(giftSubInfo)
                    } else {
                        self = .anonSubGift(giftSubInfo)
                    }
                    
                case "submysterygift":
                    self = .subMysteryGift
                    
                case "giftpaidupgrade":
                    self = .giftPaidUpgrade(.init(
                        promoGiftTotal: dictionary["msg-param-promo-gift-total"].flatMap { Int($0) } ?? 0,
                        promoName: dictionary["msg-param-promo-name"] ?? "",
                        senderLogin: dictionary["msg-param-sender-login"] ?? "",
                        senderName: dictionary["msg-param-sender-name"] ?? ""
                    ))
                    
                case "rewardgift":
                    self = .rewardGift
                    
                case "anongiftpaidupgrade":
                    self = .anonGiftPaidUpgrade(.init(
                        promoGiftTotal: dictionary["msg-param-promo-gift-total"].flatMap { Int($0) } ?? 0,
                        promoName: dictionary["msg-param-promo-name"] ?? ""
                    ))
                    
                case "raid":
                    self = .raid(.init(
                        displayName: dictionary["msg-param-displayName"] ?? "",
                        login: dictionary["msg-param-login"] ?? "",
                        viewerCount: dictionary["msg-param-viewerCount"].flatMap { Int($0) } ?? 0
                    ))
                    
                case "unraid":
                    self = .unraid
                    
                case "ritual":
                    self = .ritual(name: dictionary["msg-param-ritual-name"] ?? "")
                    
                case "bitsbadgetier":
                    self = .bitsBadgeTier(threshold: dictionary["msg-param-threshold"].flatMap { Int($0) } ?? 0)
                    
                default:
                    self = .unknown(params: dictionary.filter { $0.key.hasPrefix("msg-param-") })
                }
            }
        }
        
        /// Metadata related to the chat badges in the badges tag.
        ///
        /// Currently this is used only for `subscriber`, to indicate the exact number of months the user has been
        /// a subscriber. This number is finer grained than the version number in badges. For example, a user who
        /// has been a subscriber for 45 months would have a `badge-info` value of 45 but might have a `badges`
        /// `version` number for only 3 years.
        public let badgeInfo: Int?
        
        /// Comma-separated list of chat badges and the version of each badge (each in the format
        /// `<badge>/<version>`, such as `admin/1`). There are many valid `badge` values; e.g., `admin`, `bits`,
        /// `broadcaster`, `global_mod`, `moderator`, `subscriber`, `staff`, `turbo`. Many badges have only 1
        /// version, but some badges have different versions (images), depending on how long you hold the badge
        /// status; e.g., `subscriber`.
        public let badges: [ChatBadge]
        
        /// Hexadecimal RGB color code (e.g. "#1E90FF"); the empty string if it is never set.
        public let color: String
        
        /// The user's display name. This is empty if it is never set.
        public let displayName: String
        
        /// Information to replace text in the message with emote images. This can be empty.
        public let emotes: ChatEmoteRanges
        
        /// A unique ID for the message.
        public let id: String
        
        /// The name of the user who sent the notice.
        public let login: String
        
        /// `true` if the user has a moderator badge; otherwise, `false`.
        public let isMod: Bool
        
        /// The type of notice (_not_ the ID). Valid values: `sub`, `resub`, `subgift`, `anonsubgift`,
        /// `submysterygift`, `giftpaidupgrade`, `rewardgift`, `anongiftpaidupgrade`, `raid`, `unraid`,
        /// `ritual`, `bitsbadgetier`.
        public let messageType: UserNoticeType
        
        /// The channel ID.
        public let roomId: String
        
        /// The message displayed in chat along with this notice.
        public let systemMsg: String
        
        /// Timestamp when the server received the message.
        public let tmiSentTimestamp: Int
        
        /// The user's ID.
        public let userId: String
        
        /// The channel this notice was sent to.
        public let channel: String
        
        /// The message.
        ///
        /// This is omitted if the user did not enter a message.
        public let message: String
        
        /// Whether the message is a /me message or not.
        public let isSlashMeMessage: Bool
        
        internal init(dictionary: [String: String]) throws {
            guard let channel = dictionary["channel"],
                  let id = dictionary["id"],
                  let userId = dictionary["user-id"] else {
                throw ChatMessageError.unhandledMessage
            }
            
            self.id = id
            self.userId = userId
            self.channel = channel
            
            let messageWith001ActionMaybe = dictionary["message"] ?? ""
            let message = messageWith001ActionMaybe
                .replacingOccurrences(of: "\u{01}ACTION ", with: "")
                .replacingOccurrences(of: "\u{01}", with: "")
            
            self.message = message
            
            badgeInfo = dictionary["badge-info"].flatMap { Int($0) }
            badges = (dictionary["badges"] ?? "").components(separatedBy: ",").compactMap { ChatBadge(rawValue: $0) }
            color = dictionary["color"] ?? ""
            displayName = dictionary["display-name"] ?? ""
            login = dictionary["login"] ?? ""
            isMod = dictionary["mod"] == "1"
            messageType = UserNoticeType(dictionary: dictionary)
            roomId = dictionary["room-id"] ?? ""
            systemMsg = dictionary["system-msg"] ?? ""
            tmiSentTimestamp = dictionary["tmi-sent-ts"].flatMap { Int($0) } ?? 0
            isSlashMeMessage = messageWith001ActionMaybe.contains("\u{01}ACTION ")
            emotes = .init(rawValue: dictionary["emotes"] ?? "", message: message)
        }
    }
}
