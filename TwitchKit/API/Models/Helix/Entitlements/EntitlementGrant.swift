//
//  EntitlementGrant.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Structure containing a created URL where you can upload a manifest file and notify
/// users that they have an entitlement.
public struct EntitlementGrant: Decodable {
    
    /// The URL where you will upload the manifest file. This is the URL of a pre-signed S3 bucket.
    /// Lease time: 15 minutes.
    @SafeURL
    public private(set) var url: URL?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var urlString = try container.decode(String.self, forKey: .url)
        urlString = urlString.replacingOccurrences(of: "\\u0026", with: "&")
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(forKey: .url,
                                                   in: container,
                                                   debugDescription: "Invalid URL")
        }
        
        self.url = url
    }
    
    private enum CodingKeys: String, CodingKey {
        case url
    }
}
