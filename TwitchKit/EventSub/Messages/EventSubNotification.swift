//
//  EventSubNotification.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/11/20.
//

extension EventSub {
    
    /// <#Description#>
    public struct Notification: Decodable {
        
        /// <#Description#>
        public let subscription: Subscription
        
        /// <#Description#>
        public let event: Event
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            subscription = try container.decode(Subscription.self, forKey: .subscription)
            event = try .init(container: container, subscriptionType: subscription.type)
        }
        
        internal enum CodingKeys: String, CodingKey {
            case subscription
            case event
        }
    }
}
