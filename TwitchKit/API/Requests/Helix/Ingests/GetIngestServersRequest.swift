//
//  GetIngestServersRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 9/6/21.
//

/// Returns a list of endpoints for ingesting live video into Twitch.
public struct GetIngestServersRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// Array of Ingest Server objects.
        public let ingests: [IngestServer]
    }
    
    public let apiVersion: APIVersion = .none
    public let host = "ingest.twitch.tv"
    public let path = "/ingests"
    
    // Creates a new Get Ingest Servers request.
    public init() {
        // Empty
    }
}
