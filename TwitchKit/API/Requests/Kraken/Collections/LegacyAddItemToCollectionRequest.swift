//
//  LegacyAddItemToCollectionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Adds a specified video to a specified collection.
///
/// - Note: The item ID is a video ID (not a collection item ID).
public struct LegacyAddItemToCollectionRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyCollectionItem
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The video ID of the video to add to the collection.
        public let id: String
        
        /// The type of item to add to the collection. Always "video".
        public let type = "video"
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .post
    public let path: String
    public let body: RequestBody?
    
    /// Creates a new Add Item To Collection legacy request.
    ///
    /// - Parameters:
    ///   - collectionId: The collection ID of the collection to add the video to.
    ///   - videoId: The video ID of the video to add to the collection.
    public init(collectionId: String, videoId: String) {
        path = "/collections/\(collectionId)/items"
        body = .init(id: videoId)
    }
}
