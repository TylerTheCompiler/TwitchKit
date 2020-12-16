//
//  LegacyMoveItemWithinCollectionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Moves a specified collection item to a different position within a collection.
///
/// The collection item is specified with a collection item ID returned by Get Collection.
public struct LegacyMoveItemWithinCollectionRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The position in the collection to move the item to.
        public let position: String
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .put
    public let path: String
    public let body: RequestBody?
    
    /// Creates a new Move Item Within Collection legacy request.
    ///
    /// - Parameters:
    ///   - collectionId: The collection ID of the collection in which to move the collection item.
    ///   - itemId: The collection item ID of the item to move.
    ///   - position: The position in the collection to move the item to.
    public init(collectionId: String, itemId: String, position: Int) {
        path = "/collections/\(collectionId)/items/\(itemId)"
        body = .init(position: position.description)
    }
}
