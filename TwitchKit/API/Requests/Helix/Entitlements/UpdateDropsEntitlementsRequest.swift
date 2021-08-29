//
//  UpdateDropsEntitlementsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

import Darwin

/// Updates the fulfillment status on a set of Drops entitlements, specified by their entitlement IDs.
public struct UpdateDropsEntitlementsRequest: APIRequest {
    public enum FulfillmentStatus: String {
        case claimed = "CLAIMED"
        case fulfilled = "FULFILLED"
    }
    
    public enum QueryParamKey: String {
        case entitlementIds = "entitlement_ids"
        case fulfillmentStatus = "fulfillment_status"
    }
    
    public let method: HTTPMethod = .patch
    public let path = "/entitlements/drops"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Update Drops Entitlements request.
    ///
    /// - Parameters:
    ///   - entitlementIds: An array of unique identifiers of the entitlements to update. Maximum: 100.
    ///   - status: A fulfillment status.
    public init(entitlementIds: [String] = [], status: FulfillmentStatus? = nil) {
        queryParams = entitlementIds.map {
            (.entitlementIds, $0)
        } + [
            (.fulfillmentStatus, status?.rawValue)
        ]
    }
}
