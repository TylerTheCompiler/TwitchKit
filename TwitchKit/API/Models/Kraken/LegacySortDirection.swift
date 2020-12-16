//
//  LegacySortDirection.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Direction of sorting of the returned results of a legacy API request.
public enum LegacySortDirection: String {
    
    /// Returned results are sorted by oldest first.
    case ascending = "asc"
    
    /// Returned results are sorted by newest first.
    case descending = "desc"
}
