//
//  WebhookSubscription.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A webhook subscription.
public struct WebhookSubscription: Decodable {
    
    /// The topic used in the initial subscription.
    @SafeURL
    public private(set) var topic: URL?
    
    /// The callback provided for this subscription.
    @SafeURL
    public private(set) var callback: URL?
    
    /// Date and time when this subscription expires. Encoded as RFC3339. The timezone is always UTC ("Z").
    @InternetDate
    public private(set) var expiresAt: Date
}
