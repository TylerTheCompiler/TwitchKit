//
//  UpdateUserExtensionsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Updates the activation state, extension ID, and/or version number of installed extensions for a specified user,
/// identified by a Bearer token.
///
/// If you try to activate a given extension under multiple extension types, the last write wins (and there is no
/// guarantee of write order).
public struct UpdateUserExtensionsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Equatable, Encodable {
        
        /// The updated extensions, keyed by extension type.
        public let extensionUpdates: [ExtensionType: [ExtensionUpdate]]
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var data = container.nestedContainer(keyedBy: ExtensionType.self, forKey: .data)
            
            for (extensionType, extensionUpdates) in extensionUpdates {
                let dict = Dictionary(uniqueKeysWithValues: extensionUpdates.enumerated().map { ($0, $1) })
                try data.encode(dict, forKey: extensionType)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case data
        }
    }
    
    public typealias ResponseBody = GetUserActiveExtensionsRequest.ResponseBody
    
    public let method: HTTPMethod = .put
    public let path = "/users/extensions"
    public let body: RequestBody?
    
    /// Creates a new Update User Extensions request.
    ///
    /// - Parameter extensionUpdates: A dictionary of extension updates to apply, keyed by extension type.
    public init(extensionUpdates: [ExtensionType: [ExtensionUpdate]]) {
        body = .init(extensionUpdates: extensionUpdates)
    }
}
