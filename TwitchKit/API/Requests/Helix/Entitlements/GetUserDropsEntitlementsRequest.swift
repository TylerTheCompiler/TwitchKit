//
//  GetUserDropsEntitlementsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets a list of entitlements for a given organization that have been granted to the authenticated user for a game.
public struct GetUserDropsEntitlementsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = GetDropsEntitlementsRequest.ResponseBody
    
    public enum QueryParamKey: String {
        case after
        case first
        case gameId = "game_id"
        case id
    }
    
    public let path = "/entitlements/drops"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Drops Entitlements request for the specified entitlement IDs.
    ///
    /// - Parameter entitlementIds: Unique identifiers of the entitlements.
    public init(entitlementIds: [String]) {
        self.init(entitlementIds: entitlementIds,
                  gameId: nil,
                  after: nil,
                  first: nil)
    }
    
    /// Creates a new Get Drops Entitlements request for a game for the authenticated user.
    ///
    /// If `gameId` is specified, the response contains all entitlements owned by the authenticated user for the
    /// specified game. Your organization must own the game.
    ///
    /// If `gameId` is not specified, the response contains all entitlements owned by the authenticated user with
    /// benefits owned by your organization.
    ///
    /// - Parameters:
    ///   - gameId: A Twitch Game ID
    ///   - after: The cursor used to fetch the next page of data.
    ///   - first: Maximum number of entitlements to return. Default: 20. Max: 100
    public init(gameId: String? = nil,
                after: Pagination.Cursor? = nil,
                first: Int? = nil) {
        self.init(entitlementIds: [],
                  gameId: gameId,
                  after: after,
                  first: first)
    }
    
    // MARK: - Private
    
    private init(entitlementIds: [String],
                 gameId: String?,
                 after: Pagination.Cursor?,
                 first: Int?) {
        queryParams = [
            (.gameId, gameId),
            (.after, after?.rawValue),
            (.first, first?.description)
        ] + entitlementIds.map {
            (.id, $0)
        }
    }
}
