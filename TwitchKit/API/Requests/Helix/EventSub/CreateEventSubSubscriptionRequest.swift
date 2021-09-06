//
//  CreateEventSubSubscriptionRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

/// Creates an EventSub subscription.
public struct CreateEventSubSubscriptionRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The category of the subscription that is being created.
        public let type: EventSub.SubscriptionType
        
        /// The version of the subscription type that is being created. Each subscription type has independent
        /// versioning.
        public let version: String
        
        /// Object containing custom parameters for a particular subscription.
        public let condition: EventSub.SubscriptionCondition
        
        /// Object containing notification delivery specific configuration including a `method` type (currently only
        /// `.webhook`), `callback` URL, and `secret`.
        public let transport: Transport
        
        /// Needs to be true for some subscription types.
        internal let isBatchingEnabled: Bool
    }
    
    public struct ResponseBody: Decodable {
        
        /// Array containing 1 element: the created subscription.
        public let subscriptions: [EventSub.Subscription]
        
        /// Subscription limit for client id that made the subscription creation request.
        public let limit: Int
        
        /// Total number of subscriptions for the client ID that made the subscription creation request.
        public let total: Int
        
        private enum CodingKeys: String, CodingKey {
            case subscriptions = "data"
            case limit
            case total
        }
    }
    
    /// Object containing notification delivery specific configuration including a `method` type (currently only
    /// `.webhook`), `callback` URL, and `secret`.
    public struct Transport: Equatable, Encodable {
        
        /// The transport method. Supported values are currently only `.webhook`.
        public let method: EventSub.TransportMethod
        
        /// The callback URL where the notification should be sent.
        public let callback: URL
        
        /// The secret used for verifying a signature.
        public let secret: String
        
        /// Creates a `Transport`.
        ///
        /// - Parameters:
        ///   - method: The transport method. Supported values are currently only `.webhook`.
        ///   - callback: The callback URL where the notification should be sent.
        ///   - secret: The secret used for verifying a signature.
        public init(method: EventSub.TransportMethod, callback: URL, secret: String) {
            self.method = method
            self.callback = callback
            self.secret = secret
        }
    }
    
    public let method: HTTPMethod = .post
    public let path = "/eventsub/subscriptions"
    public let body: RequestBody?
    
    /// Creates a new Create EventSub Subscription request.
    ///
    /// - Parameters:
    ///   - condition: Object containing custom parameters for a particular subscription.
    ///   - transport: Object containing notification delivery specific configuration including a `method` type
    ///                (currently only `.webhook`), `callback` URL, and `secret`.
    ///   - version: The version of the subscription type that is being created. Each subscription type has independent
    ///              versioning. Default: "1".
    public init(condition: EventSub.SubscriptionCondition,
                transport: Transport,
                version: String = "1") {
        self.body = .init(
            type: condition.subscriptionType,
            version: version,
            condition: condition,
            transport: transport,
            isBatchingEnabled: condition.subscriptionType.isBatchingEnabled
        )
    }
    
    /// Creates a new Create EventSub subscription request with the default transport method
    /// of `.webhook` and default subscription version of `"1"`.
    ///
    /// - Parameters:
    ///   - condition: Object containing custom parameters for a particular subscription.
    ///   - callbackURL: The callback URL where the notification should be sent.
    ///   - secret: The secret used for verifying a signature.
    public init(condition: EventSub.SubscriptionCondition,
                callbackURL: URL,
                secret: String) {
        self.init(
            condition: condition,
            transport: .init(
                method: .webhook,
                callback: callbackURL,
                secret: secret
            )
        )
    }
}
