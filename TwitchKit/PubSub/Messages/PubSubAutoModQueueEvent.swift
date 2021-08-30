//
//  PubSubAutoModQueueEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub.Message {
    
    /// Status of the chat message.
    public enum ChatMessageStatus: String, Decodable {
        case pending = "PENDING"
        case allowed = "ALLOWED"
        case denied = "DENIED"
        case expired = "EXPIRED"
    }
    
    /// A PubSub event received when AutoMod flags a message as potentially inappropriate, and when a
    /// moderator takes action on a message.
    public struct AutoModQueueEvent: Decodable {
        
        /// Details about the message.
        public struct Content: Decodable {
            
            /// A potentially inappropriate part of the message.
            public struct Fragment: Decodable {
                
                public struct AutoMod: Decodable {
                    public let topics: [String: Int]
                }
                
                public let text: String
                public let automod: AutoMod
            }
            
            /// The text of the message
            public let text: String
            
            /// Defines the potentially inappropriate content of the message
            public let fragments: [Fragment]
        }
        
        /// Represents the sender of the message
        public struct Sender: Decodable {
            public let userId: String
            public let login: String
            public let displayName: String
            public let chatColor: String
        }
        
        /// The message that was caught by AutoMod.
        public struct CaughtMessage: Decodable {
            
            /// Identifier of the message
            public let id: String
            
            /// Contains details about the message
            public let content: Content
            
            /// Represents the sender of the message
            public let sender: Sender
            
            @InternetDateWithOptionalFractionalSeconds
            public private(set) var sentAt: Date
        }
        
        /// Defines the category and level that the content was classified as.
        public struct ContentClassification: Decodable {
            
            /// Category that the message was classified as.
            public let category: String
            
            /// The level that the message was classified as.
            public let level: Int
        }
        
        /// Additional `AutoModQueueEvent` info.
        public struct Data: Decodable {
            
            /// The message of the event.
            public let message: CaughtMessage
            
            /// Defines the category and level that the content was classified as.
            public let contentClassification: ContentClassification
            
            /// Current status of the message.
            public let status: ChatMessageStatus
            
            /// Reserved for internal use.
            public let reasonCode: String
            
            /// User ID of the moderator that resolved this message.
            public let resolverId: String
            
            /// User login of the moderator that resolved this message.
            public let resolverLogin: String
        }
        
        /// The type of message.
        public let type: String
        
        /// Additional event info.
        public let data: Data
    }
}
