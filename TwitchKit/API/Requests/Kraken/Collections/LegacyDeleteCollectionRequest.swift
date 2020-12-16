//
//  LegacyDeleteCollectionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Deletes a specified collection.
public struct LegacyDeleteCollectionRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .delete
    public let path: String
    
    /// Creates a new Delete Collection legacy request.
    ///
    /// - Parameter collectionId: The collection ID of the collection to delete.
    public init(collectionId: String) {
        path = "/collections/\(collectionId)"
    }
}
