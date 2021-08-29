//
//  GetChanneliCalendarRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// Gets all scheduled broadcasts from a channel's [stream schedule][1] as an [iCalendar][2].
///
/// [1]: https://help.twitch.tv/s/article/channel-page-setup#Schedule
/// [2]: https://datatracker.ietf.org/doc/html/rfc5545
public struct GetChanneliCalendarRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public typealias ResponseBody = Data
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let path = "/schedule/icalendar"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Channel iCalendar request.
    ///
    /// - Parameters:
    ///   - broadcasterId: User ID of the broadcaster who owns the channel streaming schedule.
    public init(broadcasterId: String? = nil) {
        queryParams = [(.broadcasterId, broadcasterId)]
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
