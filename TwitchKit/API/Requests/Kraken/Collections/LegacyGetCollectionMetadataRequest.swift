//
//  LegacyGetCollectionMetadataRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets summary information about a specified collection. This does not return the collection items (videos).
public struct LegacyGetCollectionMetadataRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyCollection
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get Collection Metadata legacy request.
    ///
    /// - Parameter collectionId: The collection ID of the collection whose metadata to get.
    public init(collectionId: String) {
        path = "/collections/\(collectionId)"
    }
}
