//
//  AutoModMessage.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Represents a message sent by a user to a chat room. Used for checking whether a message would be
/// accepted or rejected by AutoMod in a channel.
public struct AutoModMessage: Equatable, Encodable {
    
    /// Developer-generated identifier for mapping messages to results.
    public let id: String
    
    /// Message text.
    public let text: String
    
    /// User ID of the sender.
    public let userId: String
    
    /// Creates an `AutoModMessage` with the given parameters.
    ///
    /// - Parameters:
    ///   - id: Developer-generated identifier for mapping messages to results.
    ///   - text: Message text.
    ///   - userId: User ID of the sender.
    public init(id: String, text: String, userId: String) {
        self.id = id
        self.text = text
        self.userId = userId
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "msgId"
        case text = "msgText"
        case userId
    }
}
