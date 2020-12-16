//
//  GetVideosRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Gets video information by video ID (one or more), user ID (one only), or game ID (one only).
public struct GetVideosRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The returned list of videos.
        public let videos: [Video]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case videos = "data"
            case cursor = "pagination"
        }
    }
    
    /// Period during which a video is created for a Get Videos request.
    public enum Period: String {
        case all
        case day
        case week
        case month
    }
    
    /// Sort order of videos for a Get Videos request.
    public enum Sort: String {
        case time
        case trending
        case views
    }
    
    /// Type of video to return for a Get Videos request.
    public enum VideoType: String {
        case all
        case upload
        case archive
        case highlight
    }
    
    public enum QueryParamKey: String {
        case after
        case before
        case first
        case gameId = "game_id"
        case id
        case language
        case period
        case sort
        case type
        case userId = "user_id"
    }
    
    public let path = "/videos"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Videos request for the specified video IDs.
    ///
    /// - Parameter videoIds: IDs of the videos being queried. Limit: 100.
    public init(videoIds: [String]) {
        self.init(videoIds: videoIds,
                  cursor: nil,
                  first: nil,
                  gameId: nil,
                  language: nil,
                  period: nil,
                  sort: nil,
                  type: nil,
                  userId: nil)
    }
    
    /// Creates a new Get Videos request for the videos owned by a user.
    ///
    /// - Parameters:
    ///   - userId: ID of the user who owns the videos.
    ///   - language: Language of the videos being queried.
    ///   - period: Period during which the videos were created. Default: `.all`.
    ///   - sort: Sort order of the videos. Default: `.time`.
    ///   - type: Type of video to return. Default: `.all`.
    ///   - first: Number of values to be returned. Limit: 100. Default: 20.
    public init(userId: String,
                language: String?,
                period: Period?,
                sort: Sort?,
                type: VideoType?,
                first: Int? = nil) {
        self.init(videoIds: [],
                  cursor: nil,
                  first: first,
                  gameId: nil,
                  language: language,
                  period: period,
                  sort: sort,
                  type: type,
                  userId: userId)
    }
    
    /// Creates a new Get Videos request for the videos of a game.
    ///
    /// - Parameters:
    ///   - gameId: ID of the game the video is of.
    ///   - language: Language of the videos being queried.
    ///   - period: Period during which the videos were created. Default: `.all`.
    ///   - sort: Sort order of the videos. Default: `.time`.
    ///   - type: Type of video to return. Default: `.all`.
    ///   - first: Number of values to be returned. Limit: 100. Default: 20.
    public init(gameId: String,
                language: String?,
                period: Period?,
                sort: Sort?,
                type: VideoType?,
                first: Int? = nil) {
        self.init(videoIds: [],
                  cursor: nil,
                  first: first,
                  gameId: gameId,
                  language: language,
                  period: period,
                  sort: sort,
                  type: type,
                  userId: nil)
    }
    
    /// Creates a new Get Videos request using a pagination cursor.
    ///
    /// - Parameters:
    ///   - cursor: Cursor for forward pagination.
    ///   - first: Number of values to be returned when getting videos by user or game ID. Limit: 100. Default: 20.
    public init(cursor: Pagination.DirectedCursor, first: Int? = nil) {
        self.init(videoIds: [],
                  cursor: cursor,
                  first: first,
                  gameId: nil,
                  language: nil,
                  period: nil,
                  sort: nil,
                  type: nil,
                  userId: nil)
    }
    
    // MARK: - Private
    
    private init(videoIds: [String],
                 cursor: Pagination.DirectedCursor?,
                 first: Int?,
                 gameId: String?,
                 language: String?,
                 period: Period?,
                 sort: Sort?,
                 type: VideoType?,
                 userId: String?) {
        queryParams = [
            (.after, cursor?.forwardRawValue),
            (.before, cursor?.backwardRawValue),
            (.first, first?.description),
            (.gameId, gameId),
            (.language, language),
            (.period, period?.rawValue),
            (.sort, sort?.rawValue),
            (.type, type?.rawValue),
            (.userId, userId)
        ] + videoIds.map {
            (.id, $0)
        }
    }
}
