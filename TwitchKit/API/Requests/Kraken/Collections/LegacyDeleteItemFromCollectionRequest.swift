//
//  LegacyDeleteItemFromCollectionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Deletes a specified collection item from a specified collection, if it exists.
///
/// The collection item is specified with a collection item ID returned by Get Collection.
public struct LegacyDeleteItemFromCollectionRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .delete
    public let path: String
    
    /// Creates a new Delete Item From Collection legacy request.
    ///
    /// - Parameters:
    ///   - collectionId: The collection ID of the collection from which to delete the item.
    ///   - itemId: The collection item ID of the item to delete.
    public init(collectionId: String, itemId: String) {
        path = "/collections/\(collectionId)/items/\(itemId)"
    }
}
