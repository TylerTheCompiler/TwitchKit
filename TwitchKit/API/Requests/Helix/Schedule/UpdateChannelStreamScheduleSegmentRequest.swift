//
//  UpdateChannelStreamScheduleSegmentRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// Update a single scheduled broadcast or a recurring scheduled broadcast for a channel's [stream schedule][1].
///
/// [1]: https://help.twitch.tv/s/article/channel-page-setup#Schedule
public struct UpdateChannelStreamScheduleSegmentRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Encodable {
        
        /// Start time for the scheduled broadcast.
        public let startTime: String?
        
        /// Duration of the scheduled broadcast in minutes from the `startTime`.
        public let duration: String?
        
        /// Game/Category ID for the scheduled broadcast.
        public let categoryId: String?
        
        /// Title for the scheduled broadcast. Maximum: 140 characters.
        public let title: String?
        
        /// Indicates if the scheduled broadcast is canceled.
        public let isCanceled: Bool?
        
        /// The timezone of the application creating the scheduled broadcast.
        public let timezone: String?
    }
    
    public struct ResponseBody: Decodable {
        
        /// The stream schedule with the newly created segment.
        public let schedule: Schedule
        
        private enum CodingKeys: String, CodingKey {
            case schedule = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case id
    }
    
    public let method: HTTPMethod = .patch
    public let path = "/schedule/segment"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    public let body: RequestBody?
    
    /// Creates a new Update Channel Stream Schedule Segment request.
    ///
    /// - Parameters:
    ///   - segmentId: The ID of the streaming segment to update.
    ///   - startTime: Start time for the scheduled broadcast. Default: nil
    ///   - duration: Duration of the scheduled broadcast in minutes from the `startTime`. Default: nil
    ///   - categoryId: Game/Category ID for the scheduled broadcast. Default: nil
    ///   - title: Title for the scheduled broadcast. Maximum: 140 characters. Default: nil
    ///   - isCanceled: Indicates if the scheduled broadcast is canceled. Default: nil
    ///   - timeZone: The timezone of the application creating the scheduled broadcast. Default: nil
    public init(segmentId: String,
                startTime: Date? = nil,
                duration: Int? = nil,
                categoryId: String? = nil,
                title: String? = nil,
                isCanceled: Bool? = nil,
                timeZone: TimeZone? = nil) {
        queryParams = [(.id, segmentId)]
        body = .init(
            startTime: startTime.map { DateFormatter.rfc3339DateFormatter.string(from: $0) },
            duration: duration?.description,
            categoryId: categoryId,
            title: title,
            isCanceled: isCanceled,
            timezone: timeZone?.identifier
        )
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
