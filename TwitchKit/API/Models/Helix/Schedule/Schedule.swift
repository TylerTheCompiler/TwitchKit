//
//  Schedule.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/29/21.
//

/// A channel's streaming schedule.
public struct Schedule: Decodable {
    
    /// A scheduled broadcast for a stream schedule.
    public struct Segment: Decodable {
        
        /// The category for a scheduled broadcast.
        public struct Category: Decodable {
            
            /// Game/category ID.
            public let id: String
            
            /// Game/category name.
            public let name: String
        }
        
        /// The ID for the scheduled broadcast.
        public let id: String
        
        /// Scheduled start time for the scheduled broadcast.
        @InternetDate
        public private(set) var startTime: Date
        
        /// Scheduled end time for the scheduled broadcast.
        @InternetDate
        public private(set) var endTime: Date
        
        /// Title for the scheduled broadcast.
        public let title: String
        
        /// Indicates if the scheduled broadcast is recurring weekly.
        public let isRecurring: Bool
        
        /// Used with recurring scheduled broadcasts. Specifies the date of the next recurring broadcast if
        /// one or more specific broadcasts have been deleted in the series. Nil otherwise.
        @OptionalInternetDate
        public private(set) var canceledUntil: Date?
        
        /// The category for the scheduled broadcast. Nil if no category has been specified.
        public let category: Category?
    }
    
    /// An object representing the start and end times of a channel's vacation if Vacation Mode is enabled.
    public struct Vacation: Decodable {
        
        /// Start time for vacation specified.
        @InternetDate
        public private(set) var startTime: Date
        
        /// End time for vacation specified.
        @InternetDate
        public private(set) var endTime: Date
    }
    
    /// Scheduled broadcasts for this stream schedule.
    public let segments: [Segment]
    
    /// User ID of the broadcaster.
    public let broadcasterId: String
    
    /// Display name of the broadcaster.
    public let broadcasterName: String
    
    /// Login of the broadcaster.
    public let broadcasterLogin: String
    
    /// If Vacation Mode is enabled, this includes start and end dates for the vacation.
    /// Nil if Vacation Mode is disabled.
    public let vacation: Vacation?
}
