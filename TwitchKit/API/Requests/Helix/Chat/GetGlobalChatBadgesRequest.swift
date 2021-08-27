//
//  GetGlobalChatBadgesRequest.swift
//  GetGlobalChatBadgesRequest
//
//  Created by Tyler Prevost on 8/26/21.
//

/// Gets a list of chat badges that can be used in chat for any channel.
public struct GetGlobalChatBadgesRequest: APIRequest {
    public struct ResponseBody: Decodable {
        
        /// An array of chat badge sets.
        public let badgeSets: [BadgeSet]
        
        private enum CodingKeys: String, CodingKey {
            case badgeSets = "data"
        }
    }
    
    public let path = "/chat/badges/global"
    
    /// Creates a new Get Global Chat Badges request.
    public init() {}
}
