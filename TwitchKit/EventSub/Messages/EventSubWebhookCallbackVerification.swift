//
//  EventSubWebhookCallbackVerification.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/11/20.
//

extension EventSub {
    
    /// <#Description#>
    public struct WebhookCallbackVerification: Decodable {
        
        /// <#Description#>
        public let subscription: Subscription
        
        /// <#Description#>
        public let challenge: String
    }
}
