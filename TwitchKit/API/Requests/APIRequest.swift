//
//  APIRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// A type that represents a request to the Twitch API.
public protocol APIRequest {
    
    /// An `Encodable` type that represents the request's post body.
    ///
    /// The default type is `EmptyCodable` for requests that do not contain a post body.
    associatedtype RequestBody: Encodable = EmptyCodable
    
    /// A `Decodable` type that represents the request's response body.
    ///
    /// The default type is `EmptyCodable` for requests whose responses have no body.
    associatedtype ResponseBody: Decodable = EmptyCodable
    
    /// If the request type can use a user access token, this is set to `ValidatedUserAccessToken`
    /// (the default). If the request type does not support using a user access token, this should
    /// be set to `IncompatibleAccessToken`.
    associatedtype UserToken: AccessToken = ValidatedUserAccessToken
    
    /// If the request type can use an app access token, this is set to `ValidatedAppAccessToken`
    /// (the default). If the request type does not support using an app access token, this should
    /// be set to `IncompatibleAccessToken`.
    associatedtype AppToken: AccessToken = ValidatedAppAccessToken
    
    /// A type that represents the keys of the query parameters of the request.
    ///
    /// The default type is `EmptyQueryParamKey` for requests that do not contain query parameters.
    associatedtype QueryParamKey: RawRepresentable & Equatable
        = EmptyQueryParamKey where QueryParamKey.RawValue == String
    
    /// The API version of the request. Default: `.helix`.
    var apiVersion: APIVersion { get }
    
    /// The HTTP method of the request. Default: `.get`.
    var method: HTTPMethod { get }
    
    /// The URL path of the request type's endpoint.
    ///
    /// This is the part of the endpoint that comes after "https://api.twitch.tv/(helix-or-kraken)" (but does not
    /// include the query parameters or fragment).
    ///
    /// It doesn't matter if the returned value starts with `"/"` or not.
    var path: String { get }
    
    /// The query parameters of the request as an array of key-value tuples. Default: an empty array.
    var queryParams: [(key: QueryParamKey, value: String?)] { get }
    
    /// The post body of the request, if any. Default: nil.
    var body: RequestBody? { get }
    
    /// Updates the request with the given user ID attached to a user access token.
    ///
    /// - Parameter userId: The user ID that was attached to a user access token.
    mutating func update(with userId: String)
}

extension APIRequest {
    
    /// The default implementation of `apiVersion`. Returns `.helix`.
    public var apiVersion: APIVersion { .helix }
    
    /// The default implementation of `method`. Returns `.get`.
    public var method: HTTPMethod { .get }
    
    /// The default implementation of `queryParams`. Returns an empty array.
    public var queryParams: [(key: QueryParamKey, value: String?)] { [] }
    
    /// The default implementation of `body`. Returns nil.
    public var body: RequestBody? { nil }
    
    /// The default implementation of `update(with:)`. Does nothing.
    ///
    /// - Parameter userId: A user ID to update the API request with. Unused in this default implementation.
    public mutating func update(with userId: String) {}
    
    internal func setIfNil(queryParam: QueryParamKey,
                           of queryParams: inout [(key: QueryParamKey, value: String?)],
                           with value: String?) {
        if queryParams.first(where: { $0.0 == queryParam })?.value == nil {
            queryParams.removeAll { $0.0 == queryParam }
            queryParams.append((queryParam, value))
        }
    }
    
    internal var equatableQueryParams: [QueryParam<QueryParamKey>] {
        queryParams.compactMap {
            guard let value = $0.value else { return nil }
            return .init($0.key, value)
        }
    }
}

struct QueryParam<Key>: Equatable where Key: Equatable {
    let key: Key
    let value: String
    
    init(_ key: Key, _ value: String) {
        self.key = key
        self.value = value
    }
}
