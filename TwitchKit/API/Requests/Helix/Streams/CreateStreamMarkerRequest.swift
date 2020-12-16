//
//  CreateStreamMarkerRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Creates a marker in the stream of a user specified by user ID.
///
/// A marker is an arbitrary point in a stream that the broadcaster wants to mark; e.g., to easily return to later.
/// The marker is created at the current timestamp in the live broadcast when the request is processed. Markers can
/// be created by the stream owner or editors. The user creating the marker is identified by a Bearer token.
///
/// Markers cannot be created in some cases (an error will occur):
///
/// * If the specified user’s stream is not live.
/// * If VOD (past broadcast) storage is not enabled for the stream.
/// * For premieres (live, first-viewing events that combine uploaded videos with live chat).
/// * For reruns (subsequent (not live) streaming of any past broadcast, including past premieres).
public struct CreateStreamMarkerRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// ID of the broadcaster in whose live stream the marker is created.
        public let userId: String
        
        /// Description of or comments on the marker. Max length is 140 characters.
        public let description: String?
    }
    
    public struct ResponseBody: Decodable {
        
        /// An array of one object - the created stream marker.
        public let streamMarkers: [StreamMarker]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case streamMarkers = "data"
            case cursor = "pagination"
        }
    }
    
    public let method: HTTPMethod = .post
    public let path = "/streams/markers"
    public let body: RequestBody?
    
    /// Creates a new Create Stream Marker request.
    ///
    /// - Parameters:
    ///   - userId: ID of the broadcaster in whose live stream the marker is created.
    ///   - description: Description of or comments on the marker. Max length is 140 characters.
    public init(userId: String, description: String? = nil) {
        body = .init(userId: userId, description: description)
    }
}
