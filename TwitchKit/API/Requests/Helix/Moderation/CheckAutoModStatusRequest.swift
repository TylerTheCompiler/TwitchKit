//
//  CheckAutoModStatusRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// Determines whether a string message meets the channel’s AutoMod requirements.
///
/// AutoMod is a moderation tool that blocks inappropriate or harassing chat with powerful moderator control.
/// AutoMod detects misspellings and evasive language automatically. AutoMod uses machine learning and natural
/// language processing algorithms to hold risky messages from chat so they can be reviewed by a channel moderator
/// before appearing to other viewers in the chat. Moderators can approve or deny any message caught by AutoMod.
///
/// For more information about AutoMod, see
/// [How to Use AutoMod](https://help.twitch.tv/s/article/how-to-use-automod?language=en_US).
public struct CheckAutoModStatusRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The messages to check with AutoMod.
        public let messages: [AutoModMessage]
        
        private enum CodingKeys: String, CodingKey {
            case messages = "data"
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
    public let path = "/moderation/enforcements/status"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    public let body: RequestBody?
    
    /// Creates a new Check AutoMod request.
    ///
    /// - Parameter messages: The messages to check with AutoMod.
    public init(messages: [AutoModMessage]) {
        queryParams = []
        body = .init(messages: messages)
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
