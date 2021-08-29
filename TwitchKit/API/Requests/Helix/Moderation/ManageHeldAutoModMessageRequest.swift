//
//  ManageHeldAutoModMessageRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/28/21.
//

import Foundation

/// Allow or deny a message that was held for review by AutoMod.
///
/// In order to retrieve messages held for review, use the `chat_moderator_actions` topic via [PubSub][1].
/// For more information about AutoMod, see [How to Use AutoMod][2].
///
/// [1]: https://dev.twitch.tv/docs/pubsub
/// [2]: https://help.twitch.tv/s/article/how-to-use-automod
public struct ManageHeldAutoModMessageRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    /// The action to take for a message held by AutoMod.
    public enum Action: String, Encodable {
        
        /// Allow the message.
        case allow = "ALLOW"
        
        /// Deny the message.
        case deny = "DENY"
    }
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The moderator who is approving or rejecting the held message. Must match the user ID in the user
        /// OAuth token.
        public var userId: String = ""
        
        /// ID of the message to be allowed or denied.
        public let messageId: String
        
        /// The action to take for the message.
        public let action: Action
        
        private enum CodingKeys: String, CodingKey {
            case messageId = "msgId"
        }
    }
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of message statuses.
        public let messageStatuses: [AutoModMessageStatus]
        
        private enum CodingKeys: String, CodingKey {
            case messageStatuses = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let method: HTTPMethod = .post
    public let path = "/moderation/automod/message"
    public private(set) var body: RequestBody?
    
    /// Creates a new Manage Held AutoMod Message request
    ///
    /// - Parameters:
    ///   - messageId: ID of the message to be allowed or denied. This ID is retrieved from PubSub.
    ///   - action: The action to take for the message.
    public init(messageId: String, action: Action) {
        body = .init(messageId: messageId, action: action)
    }
    
    public mutating func update(with userId: String) {
        body?.userId = userId
    }
}
