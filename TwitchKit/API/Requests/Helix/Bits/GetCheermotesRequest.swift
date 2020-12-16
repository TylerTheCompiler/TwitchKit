//
//  GetCheermotesRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

/// Retrieves the list of available Cheermotes, animated emotes to which viewers can assign Bits, to cheer in chat.
/// Cheermotes returned are available throughout Twitch, in all Bits-enabled channels.
public struct GetCheermotesRequest: APIRequest {
    
    public struct ResponseBody: Decodable {
        
        /// The list of returned Cheermotes.
        public let cheermotes: [Cheermote]
        
        private enum CodingKeys: String, CodingKey {
            case cheermotes = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/bits/cheermotes"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Cheermotes request.
    ///
    /// - Parameter broadcasterId: ID for the broadcaster who might own specialized Cheermotes.
    public init(broadcasterId: String? = nil) {
        queryParams = [(.broadcasterId, broadcasterId)]
    }
}
