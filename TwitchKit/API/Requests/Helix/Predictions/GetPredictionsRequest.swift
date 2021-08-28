//
//  GetPredictionsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

/// Gets information about all Channel Points Predictions or specific Channel Points Predictions for a Twitch channel.
///
/// Results are ordered by most recent, so it can be assumed that the currently active or locked Prediction will be
/// the first item.
public struct GetPredictionsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// An array of predictions in a specific channel.
        @EmptyIfNull
        public private(set) var predictions: [Prediction]
        
        /// A cursor value to be used in a subsequent request to specify the
        /// starting point of the next set of results.
        @Pagination
        public private(set) var cursor: Pagination.Cursor?
        
        private enum CodingKeys: String, CodingKey {
            case predictions = "data"
            case cursor = "pagination"
        }
    }
    
    public enum QueryParamKey: String {
        case broadcasterId = "broadcaster_id"
        case id
        case after
        case first
    }
    
    public let path = "/predictions"
    public private(set) var queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Predictions request for the predictions identified by the given prediction IDs, for the
    /// broadcaster identified by the user ID in the user auth token.
    ///
    /// - Parameters:
    ///   - predictionIds: IDs of the Predictions to return. Filters results to one or more specific Predictions.
    ///                    Not providing one or more IDs will return the full list of Predictions for the authenticated
    ///                    channel.
    ///   - first: Maximum number of objects to return. Maximum: 20. Default: 20.
    public init(predictionIds: [String] = [], first: Int = 20) {
        queryParams = [(.first, first.description)] + predictionIds.map { (.id, $0) }
    }
    
    /// Creates a new Get Predictions request with the pagination cursor obtained from a previous request.
    ///
    /// - Parameters:
    ///   - cursor: Cursor for forward pagination: tells the server where to start fetching the next set of results in a
    ///             multi-page response. The cursor value specified here is from the pagination response field of a prior
    ///             query.
    ///   - first: Maximum number of objects to return. Maximum: 20. Default: 20.
    public init(after cursor: Pagination.Cursor, first: Int = 20) {
        queryParams = [
            (.after, cursor.rawValue),
            (.first, first.description)
        ]
    }
    
    public mutating func update(with userId: String) {
        setIfNil(queryParam: .broadcasterId, of: &queryParams, with: userId)
    }
}
