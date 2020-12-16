//
//  ChatMessageRoomState.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// A message containing room-state data sent when the chatbot joins a channel or a room setting is changed.
    /// For a join, the message contains all chat-room settings. For changes, only the relevant tag is sent.
    public struct RoomState {
        
        /// Describes the follower requirements for chatting in a channel's chat.
        public enum FollowersOnlyMode: RawRepresentable {
            
            /// All users can chat, regardless of whether they follow the channel or not.
            case disabled
            
            /// Only followers may chat in the channel. There is no minimum amount of time they must follow for.
            case allFollowersCanChat
            
            /// Only followers who have followed for at least the given number of minutes may chat in the channel.
            case minFollowTime(minutes: Int)
            
            public var rawValue: Int {
                switch self {
                case .disabled: return -1
                case .allFollowersCanChat: return 0
                case .minFollowTime(let minutes): return minutes
                }
            }
            
            public init(rawValue: Int) {
                switch rawValue {
                case ..<0: self = .disabled
                case 0: self = .allFollowersCanChat
                default: self = .minFollowTime(minutes: rawValue)
                }
            }
        }
        
        /// Emote-only mode.
        ///
        /// If enabled, only emotes are allowed in chat. Valid values: 0 (disabled) or 1 (enabled).
        public let isEmoteOnly: Bool?
        
        /// Followers-only mode.
        ///
        /// If enabled, controls which followers can chat. Valid values: -1 (disabled), 0 (all followers can chat),
        /// or a non-negative integer (only users following for at least the specified number of minutes can chat).
        public let followersOnly: FollowersOnlyMode?
        
        /// R9K mode.
        ///
        /// If enabled, messages with more than 9 characters must be unique. Valid values: 0 (disabled) or 1
        /// (enabled).
        public let isR9K: Bool?
        
        /// The number of seconds a chatter without moderator privileges must wait between sending messages.
        public let slow: Int?
        
        /// Subscribers-only mode.
        ///
        /// If enabled, only subscribers and moderators can chat. Valid values: 0 (disabled) or 1 (enabled).
        public let isSubsOnly: Bool?
        
        /// The channel this message was sent to.
        public let channel: String
        
        internal init(dictionary: [String: String]) throws {
            guard let channel = dictionary["channel"] else {
                throw ChatMessageError.unhandledMessage
            }
            
            isEmoteOnly = dictionary["emote-only"].map { $0 == "1" }
            followersOnly = dictionary["followers-only"].flatMap { Int($0) }.map { .init(rawValue: $0) }
            isR9K = dictionary["r9k"].map { $0 == "1" }
            slow = dictionary["slow"].flatMap { Int($0) }
            isSubsOnly = dictionary["subs-only"].map { $0 == "1" }
            self.channel = channel
        }
    }
}
