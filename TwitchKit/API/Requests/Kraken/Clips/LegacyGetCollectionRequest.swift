//
//  LegacyGetCollectionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets all items (videos) in a specified collection.
///
/// For each video in the collection, this returns a collection item ID and other information.
/// Collection item IDs are unique (only) within the collection.
public struct LegacyGetCollectionRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returns list of collection items.
        public let items: [LegacyCollectionItem]
        
        /// The collection ID of the returned collection items.
        public let id: String
        
        private enum CodingKeys: String, CodingKey {
            case items
            case id = "_id"
        }
    }
    
    public enum QueryParamKey: String {
        case includeAllItems = "include_all_items"
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Collection legacy request.
    ///
    /// - Parameters:
    ///   - collectionId: The collection ID of the collection to get.
    ///   - includeAllItems: If true, unwatchable VODs (private and/or in-process) are included in the response.
    ///                      Default: false.
    public init(collectionId: String, includeAllItems: Bool? = nil) {
        path = "/collections/\(collectionId)/items"
        queryParams = [(.includeAllItems, includeAllItems?.description)]
    }
}
