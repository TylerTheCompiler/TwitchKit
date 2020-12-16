//
//  ChatMessagePlainMessage.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// A message sent from a channel when a user sends a message to the channel (via the PRIVMSG command).
    public struct PlainMessage {
        
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
        
        /// The amount of cheer/Bits employed by the user. Sent only for Bits messages.
        public let bits: Int
        
        /// Hexadecimal RGB color code (e.g. "#1E90FF"); the empty string if it is never set.
        public let color: String
        
        /// The user's display name. This is empty if it is never set.
        public let displayName: String
        
        /// Information to replace text in the message with emote images. This can be empty.
        public let emotes: ChatEmoteRanges
        
        /// A unique ID for the message.
        public let id: String
        
        /// `true` if the user has a moderator badge; otherwise, `false`.
        public let isMod: Bool
        
        /// The channel ID.
        public let roomId: String
        
        /// Timestamp when the server received the message.
        public let tmiSentTimestamp: Int
        
        /// The user's ID.
        public let userId: String
        
        /// The channel this message was sent to.
        public let channel: String
        
        /// The message.
        public let message: String
        
        /// The username of the user who sent the message.
        public let sendingUser: String
        
        /// Whether the message is a /me message or not.
        public let isSlashMeMessage: Bool
        
        internal init(dictionary: [String: String]) throws {
            guard let channel = dictionary["channel"],
                  let sendingUser = dictionary["user"],
                  let messageWith001ActionMaybe = dictionary["message"],
                  let id = dictionary["id"],
                  let userId = dictionary["user-id"] else {
                throw ChatMessageError.unhandledMessage
            }
            
            self.id = id
            self.userId = userId
            self.channel = channel
            self.sendingUser = sendingUser
            
            let message = messageWith001ActionMaybe
                .replacingOccurrences(of: "\u{01}ACTION ", with: "")
                .replacingOccurrences(of: "\u{01}", with: "")
            
            self.message = message
            
            badgeInfo = dictionary["badge-info"].flatMap { Int($0) }
            badges = (dictionary["badges"] ?? "").components(separatedBy: ",").compactMap { ChatBadge(rawValue: $0) }
            bits = dictionary["bits"].flatMap { Int($0) } ?? 0
            color = dictionary["color"] ?? ""
            displayName = dictionary["display-name"] ?? ""
            isMod = dictionary["mod"] == "1"
            roomId = dictionary["room-id"] ?? ""
            tmiSentTimestamp = dictionary["tmi-sent-ts"].flatMap { Int($0) } ?? 0
            isSlashMeMessage = messageWith001ActionMaybe.contains("\u{01}ACTION ")
            emotes = .init(rawValue: dictionary["emotes"] ?? "", message: message)
        }
    }
}
