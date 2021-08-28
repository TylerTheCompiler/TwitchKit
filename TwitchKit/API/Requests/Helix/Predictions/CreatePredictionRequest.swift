//
//  CreatePredictionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

/// Creates a Channel Points Prediction for a specific Twitch channel.
public struct CreatePredictionRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Encodable {
        
        /// Represents an outcome of a Twitch channel points prediction.
        internal struct Outcome: Encodable {
            
            /// Text displayed for the outcome choice.
            ///
            /// Maximum: 25 characters.
            internal var title: String
            
            /// Creates a new prediction outcome with the given title.
            ///
            /// - Parameter title: Text displayed for the choice. Maximum: 25 characters.
            internal init(title: String) {
                self.title = title
            }
        }
        
        /// The broadcaster running predictions. Must match the user ID in the user OAuth token.
        internal var broadcasterId: String = ""
        
        /// Title for the Prediction.
        ///
        /// Maximum: 45 characters.
        internal var title: String
        
        /// Array of outcome objects with titles for the Prediction.
        ///
        /// Array size must be 2. The first outcome object is the "blue" outcome and the second outcome
        /// object is the "pink" outcome when viewing the Prediction on Twitch.
        internal var outcomes: [Outcome]
        
        /// Total duration for the Prediction (in seconds).
        ///
        /// Minimum: 1. Maximum: 1800.
        internal var predictionWindow: Int
    }
    
    public struct ResponseBody: Decodable {
        
        /// The prediction that was created.
        @ArrayOfOne
        public private(set) var prediction: Prediction
        
        private enum CodingKeys: String, CodingKey {
            case prediction = "data"
        }
    }
    
    public let method: HTTPMethod = .post
    public let path = "/predictions"
    public private(set) var body: RequestBody?
    
    /// Creates a new Create Prediction request.
    ///
    /// - Parameters:
    ///   - title: Title for the Prediction.. Maximum: 45 characters.
    ///   - blueOutcome: Text displayed for the "blue" outcome choice, shown to users. Maximum: 25 characters.
    ///   - pinkOutcome: Text displayed for the "pink" outcome choice, shown to users. Maximum: 25 characters.
    ///   - predictionWindow: Total duration for the Prediction (in seconds).
    ///                       Minimum: 1. Maximum: 1800. Default: 180 (3 minutes)
    public init(title: String,
                blueOutcome: String,
                pinkOutcome: String,
                predictionWindow: Int = 180) {
        body = .init(
            title: title,
            outcomes: [.init(title: blueOutcome), .init(title: pinkOutcome)],
            predictionWindow: predictionWindow
        )
    }
    
    public mutating func update(with userId: String) {
        body?.broadcasterId = userId
    }
}
