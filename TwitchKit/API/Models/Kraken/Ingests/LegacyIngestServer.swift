//
//  LegacyIngestServer.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Metadata about a server used for sending stream video and audio data to (aka an ingest server).
public struct LegacyIngestServer: Decodable {
    
    /// The ID of the ingest server.
    public let id: Int
    
    /// Whether the ingest server is currently available or not.
    public let availability: Double
    
    /// Whether the ingest server is a default one or not.
    public let isDefault: Bool
    
    /// The name of the ingest server.
    public let name: String
    
    /// The `rtmp://` URL template where a stream's video and audio data is sent to.
    public let urlTemplate: TemplateURL<StreamKeyTemplateURLStrategy>
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case availability
        case isDefault = "default"
        case name
        case urlTemplate
    }
}
