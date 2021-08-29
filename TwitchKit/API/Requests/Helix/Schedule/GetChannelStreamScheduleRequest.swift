//
//  GetChannelStreamScheduleRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// Gets all scheduled broadcasts or specific scheduled broadcasts from a channel's [stream schedule][1].
///
/// Scheduled broadcasts are defined as "stream segments" in the API.
///
/// [1]: https://help.twitch.tv/s/article/channel-page-setup#Schedule
public struct GetChannelStreamScheduleRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The requested stream schedule.
        public let schedule: Schedule
        
        /// The cursor to use for future pagination requests.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case schedule = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case id
        case startTime = "start_time"
        case utcOffset = "utc_offset"
        case first
        case after
    }
    
    public let path = "/schedule"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel Stream Schedule request.
    ///
    /// - Parameters:
    ///   - broadcasterId: User ID of the broadcaster who owns the channel streaming schedule.
    ///                    Set to nil to use the user ID in the user OAuth token.
    ///   - segmentIds: The IDs of the stream segments to return. Maximum: 100.
    ///   - startTime: A timestamp in RFC3339 format to start returning stream segments from.
    ///                If not specified, the current date and time is used.
    ///   - utcOffsetInMinutes: A timezone offset for the requester specified in minutes. This is recommended
    ///                         to ensure stream segments are returned for the correct week. For example, a
    ///                         timezone that is +4 hours from GMT would be 240. If not specified, 0 is used
    ///                         for GMT.
    public init(broadcasterId: String? = nil,
                segmentIds: [String] = [],
                startTime: Date? = nil,
                utcOffsetInMinutes: Int? = nil) {
        queryParams = segmentIds.map {
            (.id, $0)
        } + [
            (.broadcasterId, broadcasterId),
            (.startTime, startTime.flatMap { DateFormatter.rfc3339DateFormatter.string(from: $0) }),
            (.utcOffset, utcOffsetInMinutes?.description)
        ]
    }
    
    /// Creates a new Get Channel Stream Schedule pagination request.
    ///
    /// - Parameters:
    ///   - cursor: Cursor for forward pagination: tells the server where to start fetching the next set of
    ///             results in a multi-page response. The cursor value specified here is from the pagination
    ///             response field of a prior query.
    ///   - first: Maximum number of stream segments to return. Maximum: 25. Default: 20.
    public init(after cursor: Pagination.Cursor, first: Int? = nil) {
        queryParams = [
            (.after, cursor.rawValue),
            (.first, first?.description)
        ]
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
