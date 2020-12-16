//
//  EventSubTransportMethod.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub {
    
    /// How an EventSub subscription should transfer information between server and client.
    public enum TransportMethod: String, Codable {
        
        /// The transfer method that uses webhooks. Currently the only supported transport method.
        case webhook
    }
}
