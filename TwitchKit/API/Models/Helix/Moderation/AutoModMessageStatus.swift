//
//  AutoModMessageStatus.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// The status of a message checked by AutoMod.
public struct AutoModMessageStatus: Decodable {
    
    /// The `id` of the `Message` this status corresponds to.
    public let id: String
    
    /// Indicates if this message meets AutoMod requirements.
    public let isPermitted: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id = "msgId"
        case isPermitted
    }
}
