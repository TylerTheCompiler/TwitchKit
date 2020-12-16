//
//  LegacyGetLiveStreamsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a list of live streams.
public struct LegacyGetLiveStreamsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of streams.
        public let streams: [LegacyStream]
    }
    
    /// The type of live stream to return.
    public enum StreamType: String {
        case live
        case playlist
        case all
    }
    
    public enum QueryParamKey: String {
        case channel
        case game
        case language
        case streamType = "stream_type"
        case limit
        case offset
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/streams"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Live Streams legacy request.
    ///
    /// - Parameters:
    ///   - channels: Constrains the channel(s) of the streams returned.
    ///   - game: Constrains the game of the streams returned.
    ///   - language: Constrains the language of the streams returned. Valid value: a locale ID string; for example,
    ///               "en", "fi", "es-mx". Language is mapped to the broadcast language preference.
    ///   - streamType: Constrains the type of streams returned. Playlists are offline streams of VODs
    ///                 (Video on Demand) that appear live. Default: live.
    ///   - limit: Maximum number of objects to return, sorted by number of viewers. Default: 25. Maximum: 100.
    ///   - offset: Object offset for pagination of results. Default: 0. Capped at 900.
    public init(channels: [String] = [],
                game: String? = nil,
                language: String? = nil,
                streamType: StreamType? = nil,
                limit: Int? = nil,
                offset: Int? = nil) {
        queryParams = [
            (.channel, channels.joined(separator: ",")),
            (.game, game),
            (.language, language),
            (.streamType, streamType?.rawValue),
            (.limit, limit?.description),
            (.offset, offset?.description)
        ]
    }
}
