//
//  LegacyStartChannelCommercialRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Starts a commercial (advertisement) on a specified channel. This is valid only for channels that are
/// Twitch partners. You cannot start a commercial more often than once every 8 minutes.
///
/// The length of the commercial (in seconds) is specified in the request body, with a required length parameter.
/// Valid values are 30, 60, 90, 120, 150, and 180.
///
/// There is an error response (422 Unprocessable Entity) if an invalid length is specified, an attempt is made to
/// start a commercial less than 8 minutes after the previous commercial, or the specified channel is not a Twitch
/// partner.
public struct LegacyStartChannelCommercialRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyCommercial
    
    public struct RequestBody: Equatable, Encodable {
        
        /// <#Description#>
        public let length: LegacyCommercial.Length
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .post
    public let path: String
    public let body: RequestBody?
    
    /// <#Description#>
    public init(channelId: String, length: LegacyCommercial.Length) {
        path = "/channels/\(channelId)/commercial"
        body = .init(length: length)
    }
}
