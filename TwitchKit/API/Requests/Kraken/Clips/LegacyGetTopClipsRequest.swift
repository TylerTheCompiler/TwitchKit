//
//  LegacyGetTopClipsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets the top clips which meet a specified set of parameters.
///
/// - Note: The clips service returns a maximum of 1000 clips.
public struct LegacyGetTopClipsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of top clips.
        public let clips: [LegacyClip]
        
        /// Tells the server where to start fetching the next set of results, in a multi-page response.
        public let cursor: String?
        
        private enum CodingKeys: String, CodingKey {
            case clips
            case cursor = "_cursor"
        }
    }
    
    /// The window of time to search for clips.
    public enum Period: String {
        case day
        case week
        case month
        case all
    }
    
    public enum QueryParamKey: String {
        case channel
        case cursor
        case game
        case language
        case limit
        case period
        case trending
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/clips/top"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Top Clips legacy request across all channels and games.
    ///
    /// - Parameters:
    ///   - period: The window of time to search for clips. Default: `.week`.
    ///   - trending: If true, the clips returned are ordered by popularity; otherwise, by viewcount. Default: false.
    ///   - languages: List of languages, which constrains the languages of videos returned. Examples: es, en,es,th.
    ///                If no language is specified, all languages are returned. Default: all languages.
    ///                Maximum: 28 languages.
    ///   - limit: Maximum number of most-recent objects to return. Default: 10. Maximum: 100.
    ///   - cursor: Tells the server where to start fetching the next set of results, in a multi-page response.
    public init(period: Period? = nil,
                trending: Bool? = nil,
                languages: [String] = [],
                limit: Int? = nil,
                cursor: String? = nil) {
        self.init(channelId: nil,
                  game: nil,
                  period: period,
                  trending: trending,
                  languages: languages,
                  limit: limit,
                  cursor: cursor)
    }
    
    /// Creates a new Get Top Clips legacy request for a specific channel.
    ///
    /// - Parameters:
    ///   - channelId: Channel name. Top clips for only this channel are returned.
    ///   - period: The window of time to search for clips. Default: `.week`.
    ///   - trending: If true, the clips returned are ordered by popularity; otherwise, by viewcount. Default: false.
    ///   - languages: List of languages, which constrains the languages of videos returned. Examples: es, en,es,th.
    ///                If no language is specified, all languages are returned. Default: all languages.
    ///                Maximum: 28 languages.
    ///   - limit: Maximum number of most-recent objects to return. Default: 10. Maximum: 100.
    ///   - cursor: Tells the server where to start fetching the next set of results, in a multi-page response.
    public init(channelId: String,
                period: Period? = nil,
                trending: Bool? = nil,
                languages: [String] = [],
                limit: Int? = nil,
                cursor: String? = nil) {
        self.init(channelId: channelId,
                  game: nil,
                  period: period,
                  trending: trending,
                  languages: languages,
                  limit: limit,
                  cursor: cursor)
    }
    
    /// Creates a new Get Top Clips legacy request for a specific game.
    ///
    /// - Parameters:
    ///   - game: Game name. (Game names can be retrieved with the Search Games endpoint.) Top clips for only
    ///           this game are returned.
    ///   - period: The window of time to search for clips. Default: `.week`.
    ///   - trending: If true, the clips returned are ordered by popularity; otherwise, by viewcount. Default: false.
    ///   - languages: List of languages, which constrains the languages of videos returned. Examples: es, en,es,th.
    ///                If no language is specified, all languages are returned. Default: all languages.
    ///                Maximum: 28 languages.
    ///   - limit: Maximum number of most-recent objects to return. Default: 10. Maximum: 100.
    ///   - cursor: Tells the server where to start fetching the next set of results, in a multi-page response.
    public init(game: String,
                period: Period? = nil,
                trending: Bool? = nil,
                languages: [String] = [],
                limit: Int? = nil,
                cursor: String? = nil) {
        self.init(channelId: nil,
                  game: game,
                  period: period,
                  trending: trending,
                  languages: languages,
                  limit: limit,
                  cursor: cursor)
    }
    
    // MARK: - Private
    
    private init(channelId: String?,
                 game: String?,
                 period: Period?,
                 trending: Bool?,
                 languages: [String],
                 limit: Int?,
                 cursor: String?) {
        queryParams = [
            (.channel, channelId),
            (.game, game),
            (.period, period?.rawValue),
            (.trending, trending?.description),
            (.language, languages.joined(separator: ",")),
            (.limit, limit?.description),
            (.cursor, cursor)
        ]
    }
}
