//
//  ModifyChannelInformationRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Modifies channel information for users.
public struct ModifyChannelInformationRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The current game ID being played on the channel
        public let gameId: String?
        
        /// The language of the channel
        public let broadcasterLanguage: String?
        
        /// The title of the stream
        public let title: String?
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let method: HTTPMethod = .patch
    public let path = "/channels"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    public let body: RequestBody?
    
    /// Creates a new Modify Channel Information request.
    ///
    /// - Parameters:
    ///   - broadcasterId: ID of the channel to be updated.
    ///   - gameId: The current game ID being played on the channel.
    ///   - broadcasterLanguage: The language of the channel.
    ///   - title: The title of the stream.
    public init(broadcasterId: String,
                gameId: String? = nil,
                broadcasterLanguage: String? = nil,
                title: String? = nil) {
        queryParams = [(.broadcasterId, broadcasterId)]
        body = .init(gameId: gameId,
                     broadcasterLanguage: broadcasterLanguage,
                     title: title)
    }
}
