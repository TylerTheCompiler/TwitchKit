//
//  EventSubUserAuthorizationRevoke.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// A user authorization revoke event.
    ///
    /// Contains your application's client ID and the user ID of the user who revoked
    /// authorization for your application.
    public struct UserAuthorizationRevoke: Decodable {
        
        /// The client ID of the application with revoked user access.
        public let clientId: String
        
        /// The user ID for the user who has revoked authorization for your client ID.
        public let userId: String
        
        /// The user login for the user who has revoked authorization for your client ID.
        ///
        /// This is nil if the user no longer exists.
        public let userLogin: String?
        
        /// The user name for the user who has revoked authorization for your client ID.
        ///
        /// This is nil if the user no longer exists.
        public let userName: String?
    }
}
