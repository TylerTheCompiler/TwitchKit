//
//  LegacyUpdateCollectionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Updates the title of a specified collection.
public struct LegacyUpdateCollectionRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The new title of the collection.
        public let title: String
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .put
    public let path: String
    public let body: RequestBody?
    
    /// Creates a new Create Collection legacy request.
    ///
    /// - Parameters:
    ///   - collectionId: The collection ID of the collection to update.
    ///   - title: The new title of the collection.
    public init(collectionId: String, title: String) {
        path = "/collections/\(collectionId)"
        body = .init(title: title)
    }
}
