//
//  EndPredictionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

/// Locks, resolves, or cancels a Channel Points Prediction.
///
/// Active Predictions can be updated to be "locked", "resolved", or "canceled".
/// Locked Predictions can be updated to be "resolved" or "canceled".
public struct EndPredictionRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    /// The status with which a Channel Points Prediction can be ended.
    public enum Status: Encodable {
        
        /// A winning outcome has been chosen and the Channel Points have been distributed to the users who
        /// predicted the correct outcome.
        ///
        /// The associated value is the ID of the winning outcome.
        case resolved(winningOutcomeId: String)
        
        /// The Prediction has been canceled and the Channel Points have been refunded to participants.
        case canceled
        
        /// The Prediction has been locked and viewers can no longer make predictions.
        case locked
        
        var stringValue: String {
            switch self {
            case .resolved: return "RESOLVED"
            case .canceled: return "CANCELED"
            case .locked: return "LOCKED"
            }
        }
        
        var winningOutcomeId: String? {
            switch self {
            case .resolved(let winningOutcomeId): return winningOutcomeId
            case .canceled, .locked: return nil
            }
        }
    }
    
    public struct RequestBody: Encodable {
        
        /// The broadcaster running predictions. Must match the user ID in the user OAuth token.
        internal var broadcasterId: String = ""
        
        /// ID of the Prediction.
        internal let id: String
        
        /// The Prediction status to be set.
        internal let status: String
        
        /// ID of the winning outcome for the Prediction.
        ///
        /// This parameter is required if `status` is set to `.resolved`.
        internal let winningOutcomeId: String?
    }
    
    public struct ResponseBody: Decodable {
        
        /// The prediction that was ended.
        @ArrayOfOne
        public private(set) var prediction: Prediction
        
        private enum CodingKeys: String, CodingKey {
            case prediction = "data"
        }
    }
    
    public let method: HTTPMethod = .patch
    public let path = "/predictions"
    public private(set) var body: RequestBody?
    
    /// Creates a new End Prediction request.
    ///
    /// - Parameters:
    ///   - predictionId: ID of the prediction to end.
    ///   - status: The prediction status to be set.
    public init(predictionId: String, status: Status) {
        body = .init(id: predictionId, status: status.stringValue, winningOutcomeId: status.winningOutcomeId)
    }
    
    public mutating func update(with userId: String) {
        body?.broadcasterId = userId
    }
}
