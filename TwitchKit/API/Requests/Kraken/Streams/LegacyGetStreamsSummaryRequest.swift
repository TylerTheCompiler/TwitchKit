//
//  LegacyGetStreamsSummaryRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a summary of live streams.
public struct LegacyGetStreamsSummaryRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The number of channels currently live streaming the specified game,
        /// or the count of all live streams if no game was specified.
        public let channels: Int
        
        /// The total number of viewers currently viewing the streams that are streaming the specified game,
        /// or the total number of viewers currently on Twitch if no game was specified.
        public let viewers: Int
    }
    
    public enum QueryParamKey: String {
        case game
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/streams/summary"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Streams Summary legacy request.
    ///
    /// - Parameter game: Constrains the game of the streams summary returned.
    public init(game: String? = nil) {
        queryParams = [(.game, game)]
    }
}
