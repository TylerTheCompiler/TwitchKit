//
//  LegacyCreateCollectionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Creates a new collection owned by a specified channel. The user identified by the OAuth token must be the owner
/// or an editor of the specified channel.
///
/// A collection is directly related to a channel: broadcasters can create a collection of videos only from their
/// channels.
///
/// A user can own at most 100 collections.
public struct LegacyCreateCollectionRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyCollection
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The title of the collection to create.
        public let title: String
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .post
    public let path: String
    public let body: RequestBody?
    
    /// Creates a new Create Collection legacy request.
    ///
    /// - Parameters:
    ///   - channelId: The channel ID of the channel on which to create the collection.
    ///   - title: The title of the collection to create.
    public init(channelId: String, title: String) {
        path = "/channels/\(channelId)/collections"
        body = .init(title: title)
    }
}
