//
//  APIVersion.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// A version of the Twitch API.
public enum APIVersion: String {
    
    /// The newest version of the Twitch API (as of December 2020).
    case helix
    
    /// The deprecated "v5" Twitch API.
    case kraken
    
    /// A version used by a few APIs like "Get Ingest Servers".
    case none
    
    /// The prefix used for the "Authorization" header for this API version.
    ///
    /// For `.helix` this is `"Bearer"`, and for `.kraken` this is `"OAuth"`.
    public var authorizationHeaderPrefix: String {
        switch self {
        case .helix: return "Bearer"
        case .kraken: return "OAuth"
        case .none: return ""
        }
    }
}
