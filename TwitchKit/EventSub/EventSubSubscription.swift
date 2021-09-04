//
//  EventSubSubscription.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub {
    
    /// <#Description#>
    public struct Subscription: Decodable {
        
        /// <#Description#>
        public struct Transport: Decodable {
            
            /// The transport method. Supported values: webhook.
            public let method: TransportMethod
            
            /// The callback URL where the notification should be sent.
            @SafeURL
            public private(set) var callback: URL?
        }
        
        /// <#Description#>
        public enum Status: String, Decodable {
            
            /// Designates that the subscription is in an operable state and is valid.
            case enabled
            
            /// Webhook is pending verification of the callback specified in the subscription creation request.
            case webhookCallbackVerificationPending = "webhook_callback_verification_pending"
            
            /// Webhook failed verification of the callback specified in the subscription creation request.
            case webhookCallbackVerificationFailed = "webhook_callback_verification_failed"
            
            /// Notification delivery failure rate was too high.
            case notificationFailuresExceeded = "notification_failures_exceeded"
            
            /// Authorization for user(s) in the condition was revoked.
            case authorizationRevoked = "authorization_revoked"
            
            /// A user in the condition of the subscription was removed.
            case userRemoved = "user_removed"
        }
        
        /// Your client ID.
        public let id: String
        
        /// The status of the subscription.
        public let status: Status
        
        /// The notification's subscription type.
        public let type: SubscriptionType
        
        /// The version of the subscription.
        public let version: String
        
        /// Subscription-specific parameters.
        public let condition: SubscriptionCondition
        
        /// The notification delivery specific information. Includes the transport method and callback URL.
        public let transport: Transport
        
        /// The time the notification was created.
        @InternetDateWithOptionalFractionalSeconds
        public private(set) var createdAt: Date
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            status = try container.decode(Status.self, forKey: .status)
            type = try container.decode(SubscriptionType.self, forKey: .type)
            version = try container.decode(String.self, forKey: .version)
            _createdAt = try container.decode(InternetDateWithOptionalFractionalSeconds.self, forKey: .createdAt)
            transport = try container.decode(Transport.self, forKey: .transport)
            
            let conditionContainer = try container.nestedContainer(keyedBy: SubscriptionCondition.CodingKeys.self,
                                                                   forKey: .condition)
            condition = try .init(from: conditionContainer, subscriptionType: type)
        }
        
        private enum CodingKeys: String, CodingKey {
            case id
            case status
            case type
            case version
            case condition
            case createdAt
            case transport
        }
    }
}
