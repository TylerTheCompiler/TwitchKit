//
//  GetExtensionTransactionsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Get Extension Transactions allows extension back end servers to fetch a list of transactions that have occurred
/// for their extension across all of Twitch. A transaction is a record of a user exchanging Bits for an in-Extension
/// digital good.
public struct GetExtensionTransactionsRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// The returned list of extension transactions.
        public let transactions: [ExtensionTransaction]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case transactions = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case extensionId = "extension_id"
        case first
        case id
    }
    
    public let path = "/extensions/transactions"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Extension Transactions request for a specific set of transactions.
    ///
    /// - Parameters:
    ///   - extensionId: ID of the extension to list transactions for.
    ///   - transactionIds: Transaction IDs to look up.
    ///   - first: Maximum number of objects to return. Maximum: 100 Default: 20
    public init(extensionId: String,
                transactionIds: [String] = [],
                first: Int? = nil) {
        queryParams = [
            (.extensionId, extensionId),
            (.first, first?.description)
        ] + transactionIds.map {
            (.id, $0)
        }
    }
    
    /// Creates a new Get Extension Transactions request.
    ///
    /// - Parameters:
    ///   - extensionId: ID of the extension to list transactions for.
    ///   - after: The cursor used to fetch the next page of data.
    ///   - first: Maximum number of objects to return. Maximum: 100 Default: 20
    public init(extensionId: String,
                after: Pagination.Cursor?,
                first: Int? = nil) {
        queryParams = [
            (.extensionId, extensionId),
            (.first, first?.description),
            (.after, after?.rawValue)
        ]
    }
}
