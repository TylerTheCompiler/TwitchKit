//
//  EventSubChannelPollBegin.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 9/6/21.
//

extension EventSub.Event {
    
    /// A poll begin event.
    public struct ChannelPollBegin: Decodable {
        
        /// A poll choice.
        public struct Choice: Decodable {
            
            /// ID for the choice.
            public let id: String
            
            /// Text displayed for the choice.
            public let title: String
            
            /// Number of votes received via Bits.
            public let bitsVotes: Int
            
            /// Number of votes received via Channel Points.
            public let channelPointsVotes: Int
            
            /// Total number of votes received for the choice across all methods of voting.
            public let votes: Int
        }
        
        /// The Bits voting settings for the poll.
        public struct BitsVoting: Decodable {
            
            /// Indicates if Bits can be used for voting.
            public let isEnabled: Bool
            
            /// Number of Bits required to vote once with Bits.
            public let amountPerVote: Int
        }
        
        /// The Channel Points voting settings for the poll.
        public struct ChannelPointsVoting: Decodable {
            
            /// Indicates if Channel Points can be used for voting.
            public let isEnabled: Bool
            
            /// Number of Channel Points required to vote once with Channel Points.
            public let amountPerVote: Int
        }
        
        /// ID of the poll.
        public let id: String
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster login.
        public let broadcasterUserLogin: String
        
        /// The requested broadcaster display name.
        public let broadcasterUserName: String
        
        /// Question displayed for the poll.
        public let title: String
        
        /// An array of choices for the poll.
        public let choices: [Choice]
        
        /// The Bits voting settings for the poll.
        public let bitsVoting: BitsVoting
        
        /// The Channel Points voting settings for the poll.
        public let channelPointsVoting: ChannelPointsVoting
        
        /// The time the poll started.
        @InternetDateWithOptionalFractionalSeconds
        public private(set) var startedAt: Date
        
        /// The time the poll will end.
        @InternetDateWithOptionalFractionalSeconds
        public private(set) var endsAt: Date
    }
}
