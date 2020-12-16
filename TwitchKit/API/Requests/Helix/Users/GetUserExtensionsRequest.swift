//
//  GetUserExtensionsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Gets a list of all extensions (both active and inactive) for a specified user, identified by a Bearer token.
public struct GetUserExtensionsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of extensions.
        public let extensions: [TwitchExtension]
        
        private enum CodingKeys: String, CodingKey {
            case extensions = "data"
        }
    }
    
    public let path = "/users/extensions/list"
    
    /// Creates a new Get User Extensions request.
    public init() {}
}
