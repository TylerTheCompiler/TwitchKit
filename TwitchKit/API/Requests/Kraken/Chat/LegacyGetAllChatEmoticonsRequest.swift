//
//  LegacyGetAllChatEmoticonsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets all chat emoticons (including their images).
///
/// - Important: This endpoint returns a large amount of data.
public struct LegacyGetAllChatEmoticonsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// All chat emotes.
        public let emoticons: [LegacyEmoteDetail]
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/chat/emoticons"
    
    /// Creates a new Get All Chat Emoticons legacy request.
    ///
    /// - Important: This endpoint returns a large amount of data.
    public init() {}
}
