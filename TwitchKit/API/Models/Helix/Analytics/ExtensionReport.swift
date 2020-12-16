//
//  ExtensionReport.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Metadata about an Extension's report and a URL to a downloadable CSV file containing analytics data.
public struct ExtensionReport: Decodable {
    
    /// Type of report.
    public enum ReportType: String, Decodable {
        case overviewV1 = "overview_v1"
        case overviewV2 = "overview_v2"
    }
    
    /// ID of the extension whose analytics data is being provided.
    public let extensionId: String
    
    /// URL to the downloadable CSV file containing analytics data. Valid for 5 minutes.
    @SafeURL
    public private(set) var url: URL?
    
    /// Type of report.
    public let type: ReportType
    
    /// Date range of the report.
    @InternetDateInterval
    public private(set) var dateRange: DateInterval
    
    private enum CodingKeys: String, CodingKey {
        case extensionId
        case url = "URL"
        case type
        case dateRange
    }
}
