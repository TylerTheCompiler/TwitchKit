//
//  DeleteChannelStreamScheduleSegmentRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// Delete a single scheduled broadcast or a recurring scheduled broadcast for a channel's [stream schedule][1].
///
/// [1]: https://help.twitch.tv/s/article/channel-page-setup#Schedule
public struct DeleteChannelStreamScheduleSegmentRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case id
    }
    
    public let method: HTTPMethod = .delete
    public let path = "/schedule/segment"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Delete Channel Stream Schedule Segment request.
    ///
    /// - Parameter segmentId: The ID of the streaming segment to delete.
    public init(segmentId: String) {
        queryParams = [(.id, segmentId)]
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
