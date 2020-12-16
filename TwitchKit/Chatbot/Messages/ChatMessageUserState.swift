//
//  ChatMessageUserState.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// A message containing user-state data sent when a user joins a channel or sends a PRIVMSG to a channel.
    public struct UserState {
        
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
        
        /// Your emote set, a comma-separated list of emote sets.
        public let emoteSets: [Int]
        
        /// `true` if the user has a moderator badge; otherwise, `false`.
        public let isMod: Bool
        
        /// The channel this message was sent to.
        public let channel: String
        
        internal init(dictionary: [String: String]) throws {
            guard let channel = dictionary["channel"] else {
                throw ChatMessageError.unhandledMessage
            }
            
            badgeInfo = dictionary["badge-info"].flatMap { Int($0) }
            badges = (dictionary["badges"] ?? "").components(separatedBy: ",").compactMap { ChatBadge(rawValue: $0) }
            color = dictionary["color"] ?? ""
            displayName = dictionary["display-name"] ?? ""
            emoteSets = (dictionary["emote-sets"] ?? "").components(separatedBy: ",").compactMap { Int($0) }
            isMod = dictionary["mod"] == "1"
            self.channel = channel
        }
    }
}
