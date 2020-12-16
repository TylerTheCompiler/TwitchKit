//
//  GetBitsLeaderboardRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets a ranked list of Bits leaderboard information for an authorized broadcaster.
public struct GetBitsLeaderboardRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of Bits leaders.
        public let bitLeaders: [BitLeader]
        
        /// The date range for the returned data.
        @InternetDateInterval
        public private(set) var dateInterval: DateInterval
        
        /// Total number of results (users) returned. This is the value specified in the `count` query
        /// parameter or the total number of entries in the leaderboard, whichever is less.
        public let total: Int
        
        private enum CodingKeys: String, CodingKey {
            case bitLeaders = "data"
            case dateInterval = "dateRange"
            case total
        }
    }
    
    /// Time period over which data is aggregated for a Get Bits Leaderboard request.
    public enum Period {
        
        /// The lifetime of the broadcaster's channel.
        case all
        
        /// 00:00:00 on the day of the given date through 00:00:00 on the following day.
        case day(of: Date)
        
        /// From 00:00:00 on Monday of the week of the given date through 00:00:00 on the following Monday.
        case week(of: Date)
        
        /// From 00:00:00 of the first day of the month of the given date through 00:00:00 on the
        /// first day of the following month.
        case month(of: Date)
        
        /// From 00:00:00 of the first day of the year of the given date through 00:00:00 on the
        /// first day of the following year.
        case year(of: Date)
        
        internal var periodRawValue: String {
            switch self {
            case .all: return "all"
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            }
        }
        
        internal var startedAtRawValue: String? {
            switch self {
            case .all: return nil
            case .day(let startedAtDate),
                 .week(let startedAtDate),
                 .month(let startedAtDate),
                 .year(let startedAtDate):
                return ISO8601DateFormatter.internetDateFormatter.string(from: startedAtDate)
            }
        }
    }
    
    public enum QueryParamKey: String {
        case count
        case period
        case startedAt = "started_at"
        case userId = "user_id"
    }
    
    public let path = "/bits/leaderboard"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Bits Leaderboard request.
    ///
    /// - Parameters:
    ///   - count: Number of results to be returned. Maximum: 100. Default: 10.
    ///   - period: Time period over which data is aggregated.
    ///   - userId: ID of the user whose results are returned; i.e., the person who paid for the Bits.
    ///             As long as `count` is greater than 1, the returned data includes additional users, with Bits
    ///             amounts above and below the user specified by `userId`. If `userId` is nil, the endpoint returns
    ///             the Bits leaderboard data across top users (subject to the value of `count`).
    public init(count: Int? = nil,
                period: Period? = nil,
                userId: String? = nil) {
        queryParams = [
            (.count, count?.description),
            (.period, period?.periodRawValue),
            (.startedAt, period?.startedAtRawValue),
            (.userId, userId)
        ]
    }
}
