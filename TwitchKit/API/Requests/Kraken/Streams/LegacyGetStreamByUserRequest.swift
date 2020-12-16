//
//  LegacyGetStreamByUserRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets stream information (the stream object) for a specified user.
public struct LegacyGetStreamByUserRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The user's stream object, or nil if the user's channel is not live.
        public let stream: LegacyStream?
    }
    
    /// The type of live stream to return.
    public enum StreamType: String {
        case live
        case playlist
        case all
    }
    
    public enum QueryParamKey: String {
        case streamType = "stream_type"
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Stream By User legacy request.
    ///
    /// - Parameters:
    ///   - channelId: The channel ID of the channel whose stream to get.
    ///   - streamType: Constrains the type of streams returned.
    ///                 Playlists are offline streams of VODs (Video on Demand) that appear live. Default: live.
    public init(channelId: String, streamType: StreamType? = nil) {
        path = "/streams/\(channelId)"
        queryParams = [(.streamType, streamType?.rawValue)]
    }
}
