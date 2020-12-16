//
//  GetUserActiveExtensionsRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Gets information about active extensions installed by a specified user, identified by a user ID or Bearer token.
public struct GetUserActiveExtensionsRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Equatable, Decodable {
        
        /// The returned extensions, by extension type.
        public let extensions: [ExtensionType: [ActiveExtension]]
        
        internal init(extensions: [ExtensionType: [ActiveExtension]]) {
            self.extensions = extensions
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let data = try container.nestedContainer(keyedBy: ExtensionType.self, forKey: .data)
            
            var extensions = [ExtensionType: [ActiveExtension]]()
            for extensionType in ExtensionType.allCases {
                guard let dict = try data.decodeIfPresent([Int: ActiveExtension].self, forKey: extensionType) else {
                    continue
                }
                
                let extensionForType = dict.sorted { $0.key < $1.key }.map(\.value)
                extensions[extensionType] = extensionForType
            }
            
            self.extensions = extensions
        }
        
        private enum CodingKeys: String, CodingKey {
            case data
        }
    }
    
    public enum QueryParamKey: String {
        case userId = "user_id"
    }
    
    public let path = "/users/extensions/list"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get User Active Extensions request.
    ///
    /// - Parameter userId: ID of the user whose installed extensions will be returned.
    public init(userId: String? = nil) {
        queryParams = [(.userId, userId)]
    }
}
