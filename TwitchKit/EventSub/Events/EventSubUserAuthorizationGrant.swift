//
//  EventSubUserAuthorizationGrant.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// A user authorization grant event.
    ///
    /// Contains your application's client ID and the user ID of the user who granted authorization to your application.
    public struct UserAuthorizationGrant: Decodable {
        
        /// The client ID of the application that was granted user access.
        public let clientId: String
        
        /// The user ID for the user who has granted authorization for your client ID.
        public let userId: String
        
        /// The user login for the user who has granted authorization for your client ID.
        public let userLogin: String
        
        /// The user display name for the user who has granted authorization for your client ID.
        public let userName: String
    }
}
