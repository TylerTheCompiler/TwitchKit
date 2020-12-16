//
//  EventSubUserAuthorizationRevoke.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct UserAuthorizationRevoke: Decodable {
        
        /// The client_id of the application with revoked user access.
        public let clientId: String
        
        /// The user id for the user who has revoked authorization for your client id.
        public let userId: String
        
        /// The user name for the user who has revoked authorization for your client id. This is nil if the
        /// user no longer exists.
        public let userName: String?
    }
}
