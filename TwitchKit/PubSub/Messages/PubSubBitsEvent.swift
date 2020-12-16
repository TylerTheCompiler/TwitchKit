//
//  PubSubBitsEvent.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub.Message {
    
    /// A PubSub event that is received when anyone cheers in a specified channel.
    public struct BitsEvent: Decodable {
        
        /// Additional `BitsEvent` information.
        public struct Data: Decodable {
            
            /// Information about a user’s new badge level, if a cheer was not anonymous and the user reached a
            /// new badge level with a cheer.
            public struct BadgeEntitlement: Decodable {
                
                /// Value of the new Bits badge tier that was earned (1000, 10000, etc.).
                public let newVersion: Int
                
                /// Value of the previous Bits badge tier (1000, 10000, etc.).
                public let previousVersion: Int
            }
            
            /// Login name of the person who used the Bits - if the cheer was not anonymous. Nil if anonymous.
            public let userName: String?
            
            /// Name of the channel on which Bits were used.
            public let channelName: String
            
            /// User ID of the person who used the Bits - if the cheer was not anonymous. Nil if anonymous.
            public let userId: String?
            
            /// User ID of the channel on which Bits were used.
            public let channelId: String
            
            /// Chat message sent with the cheer.
            public let chatMessage: String
            
            /// Number of bits used.
            public let bitsUsed: Int
            
            /// All time total number of Bits used in the channel by a specified user.
            public let totalBitsUsed: Int
            
            /// Event type associated with this use of Bits (for example, `"cheer"`).
            public let context: String
            
            /// Information about a user’s new badge level, if the cheer was not anonymous and the user reached a
            /// new badge level with this cheer. Otherwise, nil.
            public let badgeEntitlement: BadgeEntitlement?
            
            /// Time when the Bits were used.
            @InternetDateWithFractionalSeconds
            public private(set) var time: Date
        }
        
        /// Additional event information.
        public let data: Data
        
        /// Message version
        public let version: String
        
        /// The type of object contained in `data`.
        public let messageType: String
        
        /// Message ID.
        public let messageId: String
        
        /// Whether or not the event was anonymous.
        public let isAnonymous: Bool?
    }
}
