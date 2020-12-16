//
//  GetClipsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets clip information by clip ID (one or more), broadcaster ID (one only), or game ID (one only).
///
/// Note: The clips service returns a maximum of 1000 clips.
///
/// The response has a payload with an array of clip information elements and a pagination field containing information
/// required to query for more streams.
public struct GetClipsRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The returned list of clips.
        public let clips: [Clip]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case clips = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case before
        case broadcasterId = "broadcaster_id"
        case endedAt = "ended_at"
        case first
        case gameId = "game_id"
        case id
        case startedAt = "started_at"
    }
    
    public let path = "/clips"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Clips request for a specific set of clips.
    ///
    /// - Parameters:
    ///   - clipIds: IDs of the clips being queried. Limit: 100.
    ///   - dateInterval: The date range of returned clips. The seconds value is ignored.
    public init(clipIds: [String], dateInterval: DateInterval? = nil) {
        queryParams = clipIds.map {
            (.id, $0)
        } + Self.queryParams(for: dateInterval)
    }
    
    /// Creates a new Get Clips request for a specific broadcaster.
    ///
    /// - Parameters:
    ///   - broadcasterId: ID of the broadcaster for whom clips are returned. The number of clips returned is
    ///                    determined by the `first` parameter (default: 20). Results are ordered by view count.
    ///   - cursor: Cursor for forward pagination; tells the server where to start fetching the next set of results
    ///             in a multi-page response.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    ///   - dateInterval: The date range of returned clips. The seconds value is ignored.
    public init(broadcasterId: String,
                cursor: Pagination.DirectedCursor? = nil,
                first: Int? = nil,
                dateInterval: DateInterval? = nil) {
        queryParams = [
            (.broadcasterId, broadcasterId),
            (.after, cursor?.forwardRawValue),
            (.before, cursor?.backwardRawValue),
            (.first, first?.description)
        ] + Self.queryParams(for: dateInterval)
    }
    
    /// Creates a new Get Clips request for a specific game.
    ///
    /// - Parameters:
    ///   - gameId: ID of the game for which clips are returned. The number of clips returned is determined by the
    ///             `first` parameter (default: 20). Results are ordered by view count.
    ///   - cursor: Cursor for forward pagination; tells the server where to start fetching the next set of results
    ///             in a multi-page response.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    ///   - dateInterval: The date range of returned clips. The seconds value is ignored.
    public init(gameId: String,
                cursor: Pagination.DirectedCursor? = nil,
                first: Int? = nil,
                dateInterval: DateInterval? = nil) {
        queryParams = [
            (.gameId, gameId),
            (.after, cursor?.forwardRawValue),
            (.before, cursor?.backwardRawValue),
            (.first, first?.description)
        ] + Self.queryParams(for: dateInterval)
    }
    
    // MARK: - Private
    
    private static func queryParams(for dateInterval: DateInterval?) -> [(QueryParamKey, String?)] {
        [
            (.startedAt, (dateInterval?.start).flatMap {
                ISO8601DateFormatter.internetDateFormatter.string(from: $0)
            }),
            (.endedAt, (dateInterval?.end).flatMap {
                ISO8601DateFormatter.internetDateFormatter.string(from: $0)
            })
        ]
    }
}
