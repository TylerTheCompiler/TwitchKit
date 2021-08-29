//
//  UpdateChannelStreamScheduleRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// Update the settings for a channel's [stream schedule][1]. This can be used for setting vacation details.
///
/// [1]: https://help.twitch.tv/s/article/channel-page-setup#Schedule
public struct UpdateChannelStreamScheduleRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    /// Vacation Mode channel stream schedule settings
    public enum VacationMode {
        
        /// Enable Vacation Mode. `dateRange` is the span of time for the vacation. `timeZone` is the time zone for when
        /// the vacation is scheduled.
        case enabled(dateRange: DateInterval, timeZone: TimeZone)
        
        /// Disable Vacation Mode.
        case disabled
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case isVacationEnabled = "is_vacation_enabled"
        case vacationStartTime = "vacation_start_time"
        case vacationEndTime = "vacation_end_time"
        case timeZone = "timezone"
    }
    
    public let method: HTTPMethod = .patch
    public let path = "/schedule/settings"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Update Channel Stream Schedule request.
    ///
    /// - Parameter vacationMode: The Vacation Mode settings to update the channel's stream schedule with.
    public init(vacationMode: VacationMode) {
        switch vacationMode {
        case .enabled(let dateRange, let timeZone):
            queryParams = [
                (.isVacationEnabled, "true"),
                (.vacationStartTime, DateFormatter.rfc3339DateFormatter.string(from: dateRange.start)),
                (.vacationEndTime, DateFormatter.rfc3339DateFormatter.string(from: dateRange.end)),
                (.timeZone, timeZone.identifier)
            ]
        case .disabled:
            queryParams = [
                (.isVacationEnabled, "false")
            ]
        }
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
