//
//  LegacyGetAllChatEmoticonSetsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Returns all chat emoticon sets.
///
/// - Important: This endpoint returns a large amount of data.
public struct LegacyGetAllChatEmoticonSetsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// All chat emoticons.
        public let emoticons: [LegacyEmote]
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/chat/emoticon_images"
    
    /// Creates a new Get All Chat Emoticons legacy request.
    ///
    /// - Important: This endpoint returns a large amount of data.
    public init() {}
}
