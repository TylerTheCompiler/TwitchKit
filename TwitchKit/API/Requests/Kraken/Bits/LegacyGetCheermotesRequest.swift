//
//  LegacyGetCheermotesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Retrieves the list of available cheermotes, animated emotes to which viewers can assign Bits, to cheer in chat.
///
/// The cheermotes returned are available throughout Twitch, in all Bits-enabled channels.
public struct LegacyGetCheermotesRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of cheermotes.
        public let cheermotes: [LegacyCheermote]
        
        private enum CodingKeys: String, CodingKey {
            case cheermotes = "actions"
        }
    }
    
    public enum QueryParamKey: String {
        case channelId = "channel_id"
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/bits/actions"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Cheermotes legacy request.
    ///
    /// - Parameter channelId: If this is non-nil, the cheermote for this channel is included in the response
    ///                        (if the channel owner has uploaded a channel-specific cheermote). Default: nil.
    public init(channelId: String? = nil) {
        queryParams = [(.channelId, channelId)]
    }
}
