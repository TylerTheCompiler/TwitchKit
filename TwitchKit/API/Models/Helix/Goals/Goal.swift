//
//  Goal.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 9/1/21.
//

/// A goal created by a Twitch broadcaster.
public struct Goal: Decodable {
    
    /// The type of goal.
    public enum GoalType: String, Decodable {
        
        /// The goal is to increase followers.
        case follower
        
        /// The goal is to increase subscriptions.
        case subscription
    }
    
    /// An ID that uniquely identifies this goal.
    public let id: String
    
    /// An ID that uniquely identifies the broadcaster.
    public let broadcasterId: String
    
    /// The broadcaster’s display name.
    public let broadcasterName: String
    
    /// The broadcaster’s user handle.
    public let broadcasterLogin: String
    
    /// The type of goal.
    public let type: GoalType
    
    /// A description of the goal, if specified. The description may contain a maximum of 40 characters.
    public let description: String
    
    /// The current value.
    ///
    /// If the goal is to increase followers, this field is set to the current number of followers. This number increases
    /// with new followers and decreases if users unfollow the channel.
    ///
    /// For subscriptions, `currentAmount` is increased and decreased by the points value associated with the subscription
    /// tier. For example, if a tier-two subscription is worth 2 points, `currentAmount` is increased or decreased
    /// by 2, not 1.
    public let currentAmount: Int
    
    /// The goal’s target value.
    ///
    /// For example, if the broadcaster has 200 followers before creating the goal, and their goal is to double that
    /// number, this field is set to 400.
    public let targetAmount: Int
    
    /// Indicates when the broadcaster created the goal.
    @InternetDateWithOptionalFractionalSeconds
    public private(set) var createdAt: Date
}
