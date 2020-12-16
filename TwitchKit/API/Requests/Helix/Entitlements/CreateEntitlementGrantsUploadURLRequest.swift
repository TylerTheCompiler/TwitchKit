//
//  CreateEntitlementGrantsUploadURLRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Creates a URL where you can upload a manifest file and notify users that they have an entitlement.
///
/// Entitlements are digital items that users are allowed to use. Twitch entitlements are granted to users free or as
/// part of a purchase on Twitch.
///
/// See the [Drops Guide](https://dev.twitch.tv/docs/drops) for details about using this endpoint to notify users
/// about Drops.
public struct CreateEntitlementGrantsUploadURLRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of entitlement grants.
        public let entitlementGrants: [EntitlementGrant]
        
        private enum CodingKeys: String, CodingKey {
            case entitlementGrants = "data"
        }
    }
    
    /// The type of entitlement. Currently only `.bulkDropsGrant` is supported.
    public enum EntitlementType: String {
        case bulkDropsGrant = "bulk_drops_grant"
    }
    
    public enum QueryParamKey: String {
        case manifestId = "manifest_id"
        case type
    }
    
    public let method: HTTPMethod = .post
    public let path = "/entitlements/upload"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Create Entitlement Grants Upload URL request.
    ///
    /// - Parameters:
    ///   - manifestId: Unique identifier of the manifest file to be uploaded. Must be 1-64 characters.
    ///   - type: Type of entitlement being granted. Only `.bulkDropsGrant` is supported.
    public init(manifestId: String, type: EntitlementType) {
        queryParams = [
            (.manifestId, manifestId),
            (.type, type.rawValue)
        ]
    }
}
