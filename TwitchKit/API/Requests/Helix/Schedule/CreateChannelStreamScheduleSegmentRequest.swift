//
//  CreateChannelStreamScheduleSegmentRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// Create a single scheduled broadcast or a recurring scheduled broadcast for a channel's [stream schedule][1].
///
/// - Note: Only partner/affiliates may create single scheduled broadcasts.
///
/// [1]: https://help.twitch.tv/s/article/channel-page-setup#Schedule
public struct CreateChannelStreamScheduleSegmentRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Encodable {
        
        /// Start time for the scheduled broadcast.
        public let startTime: String
        
        /// The timezone of the application creating the scheduled broadcast.
        public let timezone: String
        
        /// Indicates if the scheduled broadcast is recurring weekly.
        public let isRecurring: Bool
        
        /// Duration of the scheduled broadcast in minutes from the `startTime`.
        public let duration: String
        
        /// Game/Category ID for the scheduled broadcast.
        public let categoryId: String?
        
        /// Title for the scheduled broadcast. Maximum: 140 characters.
        public let title: String?
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
    }
    
    public let method: HTTPMethod = .post
    public let path = "/schedule/segment"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    public let body: RequestBody?
    
    /// Creates a new Create Channel Stream Schedule Segment request.
    ///
    /// - Parameters:
    ///   - startTime: Start time for the scheduled broadcast.
    ///   - timeZone: The timezone of the application creating the scheduled broadcast. Default: `.current`
    ///   - isRecurring: Indicates if the scheduled broadcast is recurring weekly. Default: true
    ///   - duration: Duration of the scheduled broadcast in minutes from the `startTime`. Default: 240
    ///   - categoryId: Game/Category ID for the scheduled broadcast. Default: nil
    ///   - title: Title for the scheduled broadcast. Maximum: 140 characters. Default: nil
    public init(startTime: Date,
                timeZone: TimeZone = .current,
                isRecurring: Bool = true,
                duration: Int = 240,
                categoryId: String? = nil,
                title: String? = nil) {
        queryParams = []
        body = .init(
            startTime: DateFormatter.rfc3339DateFormatter.string(from: startTime),
            timezone: timeZone.identifier,
            isRecurring: isRecurring,
            duration: duration.description,
            categoryId: categoryId,
            title: title
        )
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
