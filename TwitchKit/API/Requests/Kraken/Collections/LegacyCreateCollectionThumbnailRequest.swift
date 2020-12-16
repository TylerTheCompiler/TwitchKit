//
//  LegacyCreateCollectionThumbnailRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Adds the thumbnail of a specified collection item as the thumbnail for the specified collection.
///
/// The collection item – a video which must already be in the collection – is specified by `itemId`.
/// The collection item is specified with a collection item ID returned by Get Collection.
public struct LegacyCreateCollectionThumbnailRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The collection item ID of the video whose thumbnail should be used as the collection's thumbnail.
        public let itemId: String
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .put
    public let path: String
    public let body: RequestBody?
    
    /// Creates a new Create Collection Thumbnail legacy request.
    ///
    /// - Parameters:
    ///   - collectionId: The collection ID of the collection whose thumbnail is to be updated.
    ///   - itemId: The collection item ID of the video whose thumbnail should be used as the collection's thumbnail.
    public init(collectionId: String, itemId: String) {
        path = "/collections/\(collectionId)/thumbnail"
        body = .init(itemId: itemId)
    }
}
