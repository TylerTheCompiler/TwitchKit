//
//  ExtensionTransaction.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Object representing an extension transaction.
public struct ExtensionTransaction: Decodable {
    
    /// Enum of the product type. Currently `.bitsInExtension` is the only case.
    public enum ProductType: String, Decodable {
        case bitsInExtension = "BITS_IN_EXTENSION"
    }
    
    /// Object representing the product acquired, as it looked at the time of the transaction.
    public struct ProductData: Decodable {
        
        /// Object representing the cost to acquire the product.
        public struct Cost: Decodable {
            
            /// The type of cost.
            public enum CostType: String, Decodable {
                
                /// A cost type of bits.
                case bits
            }
            
            /// Number of Bits required to acquire the product.
            public let amount: Int
            
            /// Always `.bits`.
            public let type: CostType
        }
        
        /// Unique identifier for the product across the extension.
        public let sku: String
        
        /// Object representing the cost to acquire the product.
        public let cost: Cost
        
        /// Display Name of the product.
        public let displayName: String
        
        /// Flag used to indicate if the product is in development.
        public let inDevelopment: Bool
    }
    
    /// Unique identifier of the Bits in Extensions Transaction.
    public let id: String
    
    /// UTC timestamp when this transaction occurred.
    @InternetDateWithFractionalSeconds
    public private(set) var timestamp: Date
    
    /// Twitch User ID of the channel the transaction occurred on.
    public let broadcasterId: String
    
    /// Twitch Display Name of the broadcaster.
    public let broadcasterName: String
    
    /// Twitch User ID of the user who generated the transaction.
    public let userId: String
    
    /// Twitch Display Name of the user who generated the transaction.
    public let userName: String
    
    /// Enum of the product type. Currently only `.bitsInExtension`.
    public let productType: ProductType
    
    /// Object representing the product acquired, as it looked at the time of the transaction.
    public let productData: ProductData
    
    /// Set this field to twitch.ext + your extension ID.
    public let domain: String?
    
    /// Flag that denotes whether or not the data was sent over the extension pubsub to all instances of the extension.
    public let broadcast: Bool?
}
