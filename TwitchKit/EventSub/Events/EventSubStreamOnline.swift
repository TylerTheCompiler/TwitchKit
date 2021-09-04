//
//  EventSubStreamOnline.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct StreamOnline: Decodable {
        
        public enum StreamType: String, Decodable {
            case live
            case playlist
            case watchParty = "watch_party"
            case premiere
            case rerun
        }
        
        /// The event id.
        public let id: String
        
        /// The broadcaster's user id.
        public let broadcasterUserId: String
        
        /// The broadcaster's user name.
        public let broadcasterUserName: String
        
        /// The stream type. Valid values are: live, playlist, watch_party, premiere, rerun.
        public let type: StreamType
    }
}
