//
//  PubSubWhisperThreadEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub.Message {
    
    /// A PubSub event that is received when one of a user's whisper threads is updated.
    public struct WhisperThreadEvent: Decodable {
        
        /// Information about whether the thread is spam or not.
        public struct SpamInfo: Decodable {
            
            /// How likely the new message is to be spam.
            public let likelihood: String
            
            /// Whether the thread was last marked as spam or not.
            public let lastMarkedNotSpam: Int
        }
        
        /// The type of whisper event. This should always be `.thread`.
        public let type: WhisperEventType
        
        /// The ID of the thread.
        public let id: String
        
        /// Timestamp of when the thread was last read by the user.
        public let lastRead: Int
        
        /// Whether the thread is archived or not.
        public let archived: Bool
        
        /// Whether the thread is muted or not.
        public let muted: Bool
        
        /// Information about whether the thread is likely to be spam or not.
        public let spamInfo: SpamInfo
        
        /// ???
        @InternetDate
        public private(set) var whitelistedUntil: Date
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(WhisperEventType.self, forKey: .type)
            
            let dataObjectContainer = try container.nestedContainer(keyedBy: DataObjectCodingKeys.self,
                                                                    forKey: .dataObject)
            id = try dataObjectContainer.decode(String.self, forKey: .id)
            lastRead = try dataObjectContainer.decode(Int.self, forKey: .lastRead)
            archived = try dataObjectContainer.decode(Bool.self, forKey: .archived)
            muted = try dataObjectContainer.decode(Bool.self, forKey: .muted)
            spamInfo = try dataObjectContainer.decode(SpamInfo.self, forKey: .spamInfo)
            _whitelistedUntil = try dataObjectContainer.decode(InternetDate.self, forKey: .whitelistedUntil)
        }
        
        private enum CodingKeys: String, CodingKey {
            case type
            case dataObject
        }
        
        private enum DataObjectCodingKeys: String, CodingKey {
            case id
            case lastRead
            case archived
            case muted
            case spamInfo
            case whitelistedUntil
        }
    }
}
