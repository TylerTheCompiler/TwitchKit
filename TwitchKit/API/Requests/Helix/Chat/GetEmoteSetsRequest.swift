//
//  GetEmoteSetsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/26/21.
//

/// Gets emotes for one or more specified emote sets.
///
/// An emote set groups emotes that have a similar context. For example, Twitch places all the subscriber emotes
/// that a broadcaster uploads for their channel in the same emote set.
///
/// [Learn more][1]
///
/// [1]: https://dev.twitch.tv/docs/irc/emotes
public struct GetEmoteSetsRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// An array of channel-created emotes.
        @EmptyIfNull
        public private(set) var emotes: [Emote]
        
        /// A templated URL for an emote's image.
        ///
        /// Use the values from an emote's identifier, format, scale, and theme mode to replace the like-named placeholder
        /// strings in the templated URL to create a CDN (content delivery network) URL that you use to fetch the emote.
        public let templateURL: TemplateURL<EmoteImageTemplateURLStrategy>
        
        private enum CodingKeys: String, CodingKey {
            case emotes = "data"
            case templateURL = "template"
        }
    }
    
    public enum QueryParamKey: String {
        case emoteSetId = "emote_set_id"
    }
    
    public let path = "/chat/emotes/set"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Emote Sets request for one or more emote sets.
    ///
    /// - Parameter emoteSetIds: IDs that identify the emote sets. You may specify a maximum of 25 IDs.
    public init(emoteSetIds: [String]) {
        queryParams = emoteSetIds.map { (.emoteSetId, $0) }
    }
}
