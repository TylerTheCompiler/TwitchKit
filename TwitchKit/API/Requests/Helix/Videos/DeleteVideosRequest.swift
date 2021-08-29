//
//  DeleteVideosRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/28/21.
//

/// Deletes one or more videos. Videos are past broadcasts, Highlights, or uploads.
///
/// Invalid Video IDs will be ignored (i.e. IDs provided that do not have a video associated with it).
/// If the OAuth user token does not have permission to delete even one of the valid Video IDs, no videos
/// will be deleted and the response will return a 401.
public struct DeleteVideosRequest: APIRequest {
    public enum QueryParamKey: String {
        case id
    }
    
    public let method: HTTPMethod = .delete
    public let path = "/videos"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    public init(videoIds: [String]) {
        queryParams = videoIds.map { (.id, $0) }
    }
}
