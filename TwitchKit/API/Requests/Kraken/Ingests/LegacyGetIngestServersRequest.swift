//
//  LegacyGetIngestServersRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets a list of Twitch ingest servers.
///
/// The Twitch ingesting system is the first stop for a broadcast stream. An ingest server receives your stream,
/// and the ingesting system authorizes and registers streams, then prepares them for viewers.
public struct LegacyGetIngestServersRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of ingest servers.
        public let ingestServers: [LegacyIngestServer]
        
        private enum CodingKeys: String, CodingKey {
            case ingestServers = "ingests"
        }
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/ingests"
    
    /// Creates a new Get Ingest Servers request.
    public init() {}
}
