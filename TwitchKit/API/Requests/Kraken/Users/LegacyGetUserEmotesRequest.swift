//
//  LegacyGetUserEmotesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of the emojis and emoticons that the specified user can use in chat.
///
/// These are both the globally available ones and the channel-specific ones (which can be
/// accessed by any user subscribed to the channel).
public struct LegacyGetUserEmotesRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyGetChatEmoticonsBySetRequest.ResponseBody
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get User Emotes legacy request.
    ///
    /// - Parameter userId: The user ID of the user whose available emotes are to be fetched.
    public init(userId: String) {
        path = "/users/\(userId)/emotes"
    }
}
