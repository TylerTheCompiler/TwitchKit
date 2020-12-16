//
//  StartCommercialRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

public typealias AppAccessTokenForTesting = AppAccessToken

/// Starts a commercial on a specified channel.
public struct StartCommercialRequest: APIRequest {
    public typealias AppToken = AppAccessTokenForTesting
    
    public struct RequestBody: Equatable, Encodable {
        
        /// ID of the channel requesting a commercial.
        public let broadcasterId: String
        
        /// Desired length of the commercial.
        public let length: Commercial.Length
    }
    
    public struct ResponseBody: Decodable {
        
        /// An array of one element - the commercial that was started.
        public let startedCommercials: [Commercial]
        
        private enum CodingKeys: String, CodingKey {
            case startedCommercials = "data"
        }
    }
    
    public let method: HTTPMethod = .post
    public let path = "/channels/commercial"
    public private(set) var body: RequestBody?
    
    /// Creates a new Start Commercial request.
    ///
    /// - Parameter length: Desired length of the commercial.
    public init(length: Commercial.Length) {
        body = .init(broadcasterId: "", length: length)
    }
    
    public mutating func update(with userId: String) {
        // swiftlint:disable:next force_unwrapping
        body = .init(broadcasterId: userId, length: body!.length)
    }
}
