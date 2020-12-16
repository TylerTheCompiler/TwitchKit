//
//  EventSubHypeTrainContribution.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/28/20.
//

extension EventSub.Event {
    
    /// <#Description#>
    public struct HypeTrainContribution: Decodable {
        
        public enum ContributionType: String, Decodable {
            case bits
            case subscription
        }
        
        /// The ID of the user.
        public let userId: String
        
        /// The name of the user.
        public let userName: String
        
        /// Type of contribution. Valid values include `bits`, `subscription`.
        public let type: ContributionType
        
        /// The total contributed.
        public let total: Int
    }
}
