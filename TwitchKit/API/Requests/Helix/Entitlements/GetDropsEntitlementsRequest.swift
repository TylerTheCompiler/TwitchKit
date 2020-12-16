//
//  GetDropsEntitlementsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

/// Gets a list of entitlements for a given organization that have been granted to a game, user, or both.
public struct GetDropsEntitlementsRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of drops entitlements.
        public let dropsEntitlements: [DropsEntitlement]
        
        /// A cursor value to be used in a subsequent request to specify the starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case dropsEntitlements = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case after
        case first
        case gameId = "game_id"
        case id
        case userId = "user_id"
    }
    
    public let path = "/entitlements/drops"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Drops Entitlements request for the specified entitlement IDs.
    ///
    /// - Parameter entitlementIds: Unique identifiers of the entitlements.
    public init(entitlementIds: [String]) {
        self.init(entitlementIds: entitlementIds,
                  userId: nil,
                  gameId: nil,
                  after: nil,
                  first: nil)
    }
    
    /// Creates a new Get Drops Entitlements request for a user, game, or both.
    ///
    /// If both `userId` and `gameId` are specified, the response contains all entitlements for the game granted to a
    /// user. Your organization must own the game.
    ///
    /// If only `userId` is specified, the response contains all entitlements for a user with benefits owned by your
    /// organization.
    ///
    /// If only `gameId` is specified, the response contains all entitlements for all users for a game. Your
    /// organization must own the game.
    ///
    /// If neither `userId` nor `gameId` are specified, the response contains all entitlements with benefits owned by
    /// your organization.
    ///
    /// - Parameters:
    ///   - userId: A Twitch User ID
    ///   - gameId: A Twitch Game ID
    ///   - after: The cursor used to fetch the next page of data.
    ///   - first: Maximum number of entitlements to return. Default: 20. Max: 100
    public init(userId: String? = nil,
                gameId: String? = nil,
                after: Pagination.Cursor? = nil,
                first: Int? = nil) {
        self.init(entitlementIds: [],
                  userId: userId,
                  gameId: gameId,
                  after: after,
                  first: first)
    }
    
    // MARK: - Private
    
    private init(entitlementIds: [String],
                 userId: String?,
                 gameId: String?,
                 after: Pagination.Cursor?,
                 first: Int?) {
        queryParams = [
            (.userId, userId),
            (.gameId, gameId),
            (.after, after?.rawValue),
            (.first, first?.description)
        ] + entitlementIds.map {
            (.id, $0)
        }
    }
}
