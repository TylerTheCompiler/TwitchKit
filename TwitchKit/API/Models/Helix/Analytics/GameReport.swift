//
//  GameReport.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Metadata about a Game's report and a URL to a downloadable CSV file containing analytics data.
public struct GameReport: Decodable {
    
    /// Type of report.
    public enum ReportType: String, Decodable {
        case overviewV1 = "overview_v1"
        case overviewV2 = "overview_v2"
    }
    
    /// ID of the game whose analytics data is being provided.
    public let gameId: String
    
    /// URL to the downloadable CSV file containing analytics data. Valid for 5 minutes.
    public let url: URL
    
    /// Type of report.
    public let type: ReportType
    
    /// Date range of the report.
    @InternetDateInterval
    public private(set) var dateRange: DateInterval
    
    private enum CodingKeys: String, CodingKey {
        case gameId
        case url = "URL"
        case type
        case dateRange
    }
}
