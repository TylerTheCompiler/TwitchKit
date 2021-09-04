//
//  CreateClipRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Creates a clip programmatically. This returns both an ID and an edit URL for the new clip.
///
/// Note: The clips service returns a maximum of 1000 clips,
///
/// Clip creation takes time. Twitch recommends that you query Get Clips, with the clip ID that is returned here. If
/// Get Clips returns a valid clip, your clip creation was successful. If, after 15 seconds, you still have not gotten
/// back a valid clip from Get Clips, assume that the clip was not created and retry Create Clip.
///
/// This endpoint has a global rate limit, across all callers. The limit may change over time, but the response
/// includes informative headers:
///
///     Ratelimit-Helixclipscreation-Limit: <int value>
///     Ratelimit-Helixclipscreation-Remaining: <int value>
public struct CreateClipRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// An array of one object - the created clip.
        public let clips: [CreatedClip]
        
        private enum CodingKeys: String, CodingKey {
            case clips = "data"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case hasDelay = "has_delay"
    }
    
    public let method: HTTPMethod = .post
    public let path = "/clips"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Create Clip request.
    ///
    /// - Parameters:
    ///   - broadcasterId: ID of the stream from which the clip will be made.
    ///   - hasDelay: If false, the clip is captured from the live stream when the API is called; otherwise, a delay
    ///               is added before the clip is captured (to account for the brief delay between the broadcaster's
    ///               stream and the viewer's experience of that stream). Default: false.
    public init(broadcasterId: String, hasDelay: Bool? = nil) {
        queryParams = [
            (.broadcasterId, broadcasterId),
            (.hasDelay, hasDelay?.description)
        ]
    }
}
