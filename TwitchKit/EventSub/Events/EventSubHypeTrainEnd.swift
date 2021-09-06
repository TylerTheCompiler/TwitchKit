//
//  EventSubHypeTrainEnd.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// A Hype Train end event.
    public struct HypeTrainEnd: Decodable {
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster name.
        public let broadcasterUserName: String
        
        /// Current level of hype train event.
        public let level: Int
        
        /// Total points contributed to hype train.
        public let total: Int
        
        /// The contributors with the most points contributed.
        ///
        /// This is an array of objects that describe a user, the type of their hype train contribution, and
        /// their total contribution amount. Contains a maximum of two `HypeTrainContribution`s: one for the
        /// top bits contributor and one for the top subscriptions contributor (this includes gifted
        /// subscriptions).
        public let topContributions: [HypeTrainContribution]
        
        /// The timestamp at which the hype train started.
        @InternetDateWithOptionalFractionalSeconds
        public private(set) var startedAt: Date
        
        /// The timestamp at which the hype train ended.
        @InternetDateWithOptionalFractionalSeconds
        public private(set) var endedAt: Date
        
        /// The timestamp at which the hype train cooldown ends so that the next hype train can start.
        @InternetDateWithOptionalFractionalSeconds
        public private(set) var cooldownEndsAt: Date
    }
}
