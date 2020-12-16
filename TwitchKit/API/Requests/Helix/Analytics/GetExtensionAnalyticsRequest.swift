//
//  GetExtensionAnalyticsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/9/20.
//

/// Gets a URL that extension developers can use to download analytics reports (CSV files)
/// for their extensions. The URL is valid for 5 minutes.
///
/// If you specify a future date, the response will be “Report Not Found For Date Range.”
/// If you leave `dateInterval` nil, the API returns the most recent date of data.
public struct GetExtensionAnalyticsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of extension analytics reports.
        public let reports: [ExtensionReport]
        
        /// A cursor value to be used in a subsequent request to specify the
        /// starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case reports = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case endedAt = "ended_at"
        case extensionId = "extension_id"
        case first
        case startedAt = "started_at"
        case type
    }
    
    public let path = "/analytics/extensions"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Extension Analytics request for a specific extension.
    ///
    /// - Parameters:
    ///   - extensionId: Client ID value assigned to the extension when it is created. The returned URL points
    ///                  to an analytics report for just the specified extension.
    ///   - dateInterval: Starting and ending date/times for returned reports. The start time must be on or after
    ///                   January 31, 2018. If the start date is earlier than the default start date,
    ///                   the default start date is used. The report covers the entire ending date; e.g.,
    ///                   if 2018/05/01 0h 0m 0s is specified, the report covers up to 2018-05-01 23h 59m 59s.
    ///                   If the end date is later than the default end date, the default end date is used.
    ///                   Default end date: 1-2 days before the request was issued (depending on report
    ///                   availability). The returned report contains one row of data per day.
    public init(extensionId: String, dateInterval: DateInterval? = nil) {
        queryParams = [
            (.extensionId, extensionId),
            (.startedAt, (dateInterval?.start).flatMap {
                DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: $0)
            }),
            (.endedAt, (dateInterval?.end).flatMap {
                DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: $0)
            })
        ]
    }
    
    /// Creates a new Get Extension Analytics request for separate analytics reports for each of
    /// the authenticated user's extensions.
    ///
    /// The response includes multiple URLs (paginated), pointing to separate analytics reports for each of
    /// the authenticated user’s Extensions.
    ///
    /// - Parameters:
    ///   - reportType: Type of analytics report that is returned. If this is non-nil, the response includes
    ///                 one URL for the specified report type. If this is nil, the response includes multiple
    ///                 URLs (paginated), one for each report type available for the authenticated user’s
    ///                 Extensions.
    ///   - dateInterval: Starting and ending date/times for returned reports. The start time must be on or
    ///                   after January 31, 2018. If the start date is earlier than the default start date, the
    ///                   default start date is used. The report covers the entire ending date; e.g., if
    ///                   2018/05/01 0h 0m 0s is specified, the report covers up to 2018-05-01 23h 59m 59s.
    ///                   If the end date is later than the default end date, the default end date is used.
    ///                   Default end date: 1-2 days before the request was issued (depending on report
    ///                   availability). The returned report contains one row of data per day.
    ///   - first: Maximum number of objects to return. Maximum: 100. Default: 20.
    ///   - after: Cursor for forward pagination: tells the server where to start fetching the next set of
    ///            results, in a multi-page response.
    public init(reportType: ExtensionReport.ReportType? = nil,
                dateInterval: DateInterval? = nil,
                first: Int? = nil,
                after: Pagination.Cursor? = nil) {
        queryParams = [
            (.type, reportType?.rawValue),
            (.startedAt, (dateInterval?.start).flatMap {
                DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: $0)
            }),
            (.endedAt, (dateInterval?.end).flatMap {
                DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: $0)
            }),
            (.first, first?.description),
            (.after, after?.rawValue)
        ]
    }
}
