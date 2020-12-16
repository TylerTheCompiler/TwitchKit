//
//  DropsEntitlement.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// An entitlement granted from a drop.
public struct DropsEntitlement: Decodable {
    
    /// Unique Identifier of the entitlement
    public let id: String
    
    /// Identifier of the Benefit
    public let benefitId: String
    
    /// UTC timestamp in ISO format when this entitlement was granted on Twitch.
    @InternetDateWithFractionalSeconds
    public private(set) var timestamp: Date
    
    /// Twitch User ID of the user who was granted the entitlement.
    public let userId: String
    
    /// Twitch Game ID of the game that was being played when this benefit was entitled.
    public let gameId: String
}
