//
//  EventSubHypeTrainProgress.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// A Hype Train progress event.
    ///
    /// Contains Hype Train information like the level, goal, top contributors, last contribution,
    /// start time, and expiration time.
    public struct HypeTrainProgress: Decodable {
        
        /// The requested broadcaster ID.
        public let broadcasterUserId: String
        
        /// The requested broadcaster name.
        public let broadcasterUserName: String
        
        /// Current level of hype train event.
        public let level: Int
        
        /// Total points contributed to hype train.
        public let total: Int
        
        /// The number of points contributed to the Hype Train at the current level.
        public let progress: Int
        
        /// The number of points required to reach the next level.
        public let goal: Int
        
        /// The contributors with the most points contributed.
        ///
        /// This is an array of objects that describe a user, the type of their hype train contribution, and
        /// their total contribution amount. Contains a maximum of two `HypeTrainContribution`s: one for the
        /// top bits contributor and one for the top subscriptions contributor (this includes gifted
        /// subscriptions).
        public let topContributions: [HypeTrainContribution]
        
        /// The most recent contribution.
        public let lastContribution: HypeTrainContribution
        
        /// The timestamp at which the hype train started.
        @InternetDateWithOptionalFractionalSeconds
        public private(set) var startedAt: Date
        
        /// The time at which the hype train expires. The expiration is extended when the hype train reaches
        /// a new level.
        @InternetDateWithOptionalFractionalSeconds
        public private(set) var expiresAt: Date
    }
}
