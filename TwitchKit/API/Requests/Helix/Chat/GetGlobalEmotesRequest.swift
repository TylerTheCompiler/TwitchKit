//
//  GetGlobalEmotesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/26/21.
//

/// Gets all [global emotes][1].
///
/// Global emotes are Twitch-created emoticons that users can use in any Twitch chat.
///
/// [Learn more][2]
///
/// [1]: https://www.twitch.tv/creatorcamp/en/learn-the-basics/emotes/
/// [2]: https://dev.twitch.tv/docs/irc/emotes
public struct GetGlobalEmotesRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// An array of global emotes.
        public let emotes: [Emote]
        
        /// A templated URL for an emote's image.
        ///
        /// Use the values from an emote's identifier, format, scale, and theme mode to replace the like-named placeholder
        /// strings in the templated URL to create a CDN (content delivery network) URL that you use to fetch the emote.
        public var templateURL: TemplateURL<EmoteImageTemplateURLStrategy>
        
        private enum CodingKeys: String, CodingKey {
            case emotes = "data"
            case templateURL = "template"
        }
    }
    
    public let path = "/chat/emotes/global"
    
    /// Creates a new Get Global Emotes request.
    public init() {}
}
