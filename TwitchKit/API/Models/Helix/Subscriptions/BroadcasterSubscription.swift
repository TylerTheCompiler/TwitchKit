//
//  BroadcasterSubscription.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Object representing a user's subscription to a broadcaster/channel.
public struct BroadcasterSubscription: Decodable {
    
    /// The level of subscription.
    public enum Tier: String, Decodable {
        
        /// A tier one subscription.
        case tier1 = "1000"
        
        /// A tier two subscription.
        case tier2 = "2000"
        
        /// A tier three subscription.
        case tier3 = "3000"
    }
    
    /// User ID of the broadcaster.
    public let broadcasterId: String
    
    /// Login of the broadcaster.
    public let broadcasterLogin: String
    
    /// Display name of the broadcaster.
    public let broadcasterName: String
    
    /// If the subscription was gifted, this is the user ID of the gifter.
    public let gifterId: String?
    
    /// If the subscription was gifted, this is the login of the gifter.
    public let gifterLogin: String?
    
    /// If the subscription was gifted, this is the display name of the gifter.
    public let gifterName: String?
    
    /// Determines if the subscription is a gift subscription.
    public let isGift: Bool
    
    /// Type of subscription (Tier 1, Tier 2, Tier 3).
    ///
    /// 1000 = Tier 1, 2000 = Tier 2, 3000 = Tier 3 subscriptions.
    public let tier: Tier
    
    /// Name of the subscription.
    public let planName: String?
    
    /// ID of the subscribed user.
    public let userId: String?
    
    /// Display name of the subscribed user.
    public let userName: String?
    
    /// Login of the subscribed user.
    public let userLogin: String?
}
