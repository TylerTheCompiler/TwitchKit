//
//  PubSubWhisperEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub.Message {
    
    /// A PubSub event that is received when a user sends or receives a whisper.
    public struct WhisperEvent: Decodable {
        
        /// Extra data about the emotes and badges sent along with a whisper.
        public struct Tags: Decodable {
            
            /// Data about an emote in a whisper.
            public struct EmoteRange: Decodable {
                
                /// The ID of the emote, as an integer.
                public let id: Int
                
                /// The ID of the emote, as a string.
                public let emoteId: String
                
                /// The starting index (in the sent message) of the emote.
                public let start: Int
                
                /// The ending index (in the sent message) of the emote.
                public let end: Int
            }
            
            /// Data about a badge attached to a whisper.
            public struct Badge: Decodable {
                
                /// The ID of the badge.
                public let id: String
                
                /// The version of the badge.
                public let version: String
            }
            
            /// The login of the user who sent the whisper.
            public let login: String
            
            /// The display name of the user who sent the whisper.
            public let displayName: String
            
            /// The username color of the user who sent the whisper, as a hex string. Possibly empty.
            public let color: String
            
            /// The emotes and their ranges in the sent whisper message.
            public let emotes: [EmoteRange]
            
            /// The badges attached to the whisper.
            public let badges: [Badge]
        }
        
        /// Data about the recipient of a whisper.
        public struct Recipient: Decodable {
            
            /// The user ID of the whisper recipient.
            public let id: Int
            
            /// The login of the whisper recipient.
            public let username: String
            
            /// The display name of the whisper recipient.
            public let displayName: String
            
            /// The username color of the whisper recipient, as a hex string. Possibly empty.
            public let color: String
            
            /// A URL of the recipient's profile image, or nil.
            @SafeURL
            public private(set) var profileImage: URL?
        }
        
        /// The type of whisper event, whether it was a send or receive.
        public let type: WhisperEventType
        
        /// The ID of the message.
        public let messageId: String
        
        /// The ID of the whisper.
        public let id: Int
        
        /// Whisper thread ID that the whisper belongs to.
        public let threadId: String
        
        /// The body of the whisper message.
        public let body: String
        
        /// Timestamp when the whisper was sent or received.
        public let sentTs: Int
        
        /// User ID of the sending user.
        public let fromId: Int
        
        /// Extra data about the emotes and badges sent along with the whisper.
        public let tags: Tags
        
        /// Data about the recipient of the whisper.
        public let recipient: Recipient
        
        /// Some kind of nonce?
        public let nonce: String
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(WhisperEventType.self, forKey: .type)
            
            let dataObjectContainer = try container.nestedContainer(keyedBy: DataObjectCodingKeys.self,
                                                                    forKey: .dataObject)
            messageId = try dataObjectContainer.decode(String.self, forKey: .messageId)
            id = try dataObjectContainer.decode(Int.self, forKey: .id)
            threadId = try dataObjectContainer.decode(String.self, forKey: .threadId)
            body = try dataObjectContainer.decode(String.self, forKey: .body)
            sentTs = try dataObjectContainer.decode(Int.self, forKey: .sentTs)
            fromId = try dataObjectContainer.decode(Int.self, forKey: .fromId)
            tags = try dataObjectContainer.decode(Tags.self, forKey: .tags)
            recipient = try dataObjectContainer.decode(Recipient.self, forKey: .recipient)
            nonce = try dataObjectContainer.decode(String.self, forKey: .nonce)
        }
        
        private enum CodingKeys: String, CodingKey {
            case type
            case dataObject
        }
        
        private enum DataObjectCodingKeys: String, CodingKey {
            case messageId
            case id
            case threadId
            case body
            case sentTs
            case fromId
            case tags
            case recipient
            case nonce
        }
    }
}
