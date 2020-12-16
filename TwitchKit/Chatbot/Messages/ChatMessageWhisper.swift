//
//  ChatMessageWhisper.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// A private message sent to the chatbot.
    public struct Whisper {
        
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
        
        /// The ID of the whisper conversation.
        public let threadId: String
        
        /// The user's ID.
        public let userId: String
        
        /// The message.
        public let message: String
        
        /// The username of the user who sent the message.
        public let sendingUser: String
        
        /// Whether the message is a /me message or not.
        public let isSlashMeMessage: Bool
        
        internal init(dictionary: [String: String]) throws {
            guard let sendingUser = dictionary["user"],
                  let messageWith001ActionMaybe = dictionary["message"],
                  let id = dictionary["message-id"],
                  let threadId = dictionary["thread-id"],
                  let userId = dictionary["user-id"] else {
                throw ChatMessageError.unhandledMessage
            }
            
            self.id = id
            self.threadId = threadId
            self.userId = userId
            self.sendingUser = sendingUser
            
            let message = messageWith001ActionMaybe
                .replacingOccurrences(of: "\u{01}ACTION ", with: "")
                .replacingOccurrences(of: "\u{01}", with: "")
            
            self.message = message
            
            badges = (dictionary["badges"] ?? "").components(separatedBy: ",").compactMap { ChatBadge(rawValue: $0) }
            color = dictionary["color"] ?? ""
            displayName = dictionary["display-name"] ?? ""
            isSlashMeMessage = messageWith001ActionMaybe.contains("\u{01}ACTION ")
            emotes = .init(rawValue: dictionary["emotes"] ?? "", message: message)
        }
    }
}
