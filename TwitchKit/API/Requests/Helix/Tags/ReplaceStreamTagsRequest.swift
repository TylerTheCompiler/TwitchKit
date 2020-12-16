//
//  ReplaceStreamTagsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/2/20.
//

/// Applies specified tags to a specified stream, overwriting any existing tags applied to that stream.
///
/// If no tags are specified, all tags previously applied to the stream are removed. Automated tags are not affected by
/// this operation.
///
/// Tags expire 72 hours after they are applied, unless the stream is live within that time period. If the stream is
/// live within the 72-hour window, the 72-hour clock restarts when the stream goes offline. The expiration period is
/// subject to change.
public struct ReplaceStreamTagsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// IDs of tags to be applied to the stream.
        public let tagIds: [String]
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
    }
    
    public let method: HTTPMethod = .put
    public let path = "/streams/tags"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    public let body: RequestBody?
    
    /// Creates a new Replace Stream Tags request.
    ///
    /// - Parameters:
    ///   - broadcasterId: ID of the stream for which tags are to be replaced.
    ///   - tagIds: IDs of tags to be applied to the stream. Maximum of 100 supported.
    public init(broadcasterId: String, tagIds: [String] = []) {
        queryParams = [(.broadcasterId, broadcasterId)]
        body = .init(tagIds: tagIds)
    }
}
