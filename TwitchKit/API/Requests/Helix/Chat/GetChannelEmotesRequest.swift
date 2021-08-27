//
//  GetChannelEmotesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/26/21.
//

/// Gets all emotes that the specified Twitch channel created.
///
/// Broadcasters create these custom emotes for users who subscribe to or follow the channel, or cheer Bits in the channel's
/// chat window. For information about the custom emotes, see [subscriber emotes][1], [Bits tier emotes][2], and
/// [follower emotes][3].
///
/// NOTE: With the exception of custom follower emotes, users may use custom emotes in any Twitch chat.
///
/// [Learn more][4]
///
/// [1]: https://help.twitch.tv/s/article/subscriber-emote-guide
/// [2]: https://help.twitch.tv/s/article/custom-bit-badges-guide?language=bg#slots
/// [3]: https://blog.twitch.tv/en/2021/06/04/kicking-off-10-years-with-our-biggest-emote-update-ever/
/// [4]: https://dev.twitch.tv/docs/irc/emotes
public struct GetChannelEmotesRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// An array of channel-created emotes.
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
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/chat/emotes"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel Emotes request for a specific broadcaster.
    ///
    /// - Parameter broadcasterId: An ID that identifies the broadcaster to get the emotes from.
    public init(broadcasterId: String) {
        queryParams = [(.broadcasterId, broadcasterId)]
    }
}
