//
//  IngestServer.swift
//  IngestServer
//
//  Created by Tyler Prevost on 9/6/21.
//

/// A Twitch ingest server.
public struct IngestServer: Decodable {
    
    /// Sequential identifier of ingest server.
    public let id: Int
    
    /// Descriptive name of ingest server.
    public let name: String
    
    /// RTMP URL template for ingest server
    public let urlTemplate: TemplateURL<StreamKeyTemplateURLStrategy>
    
    /// Reserved for internal use.
    public let availability: Float
    
    /// Reserved for internal use.
    public let isDefault: Bool
    
    /// Reserved for internal use.
    public let priority: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case urlTemplate
        case availability
        case isDefault = "default"
        case priority
    }
}
