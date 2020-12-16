//
//  Claim.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

/// Describes a piece of data you want to get about the user authorizing your application.
public enum Claim: String, CaseIterable, CustomStringConvertible, CodingKey {
    
    /// A claim used for requesting the email address of the authorizing user.
    case email
    
    /// A claim used for requesting the email verification state of the authorizing user.
    case emailVerified
    
    /// A claim used for requesting the profile image URL of the authorizing user.
    case picture
    
    /// A claim used for requesting the display name of the authorizing user.
    case preferredUsername
    
    /// A claim used for requesting the date of the last update to the authorizing user’s profile.
    case updatedAt
    
    public var description: String { rawValue }
}

extension Set where Element == Claim {
    
    /// All claims.
    public static let all = Set(Claim.allCases)
}
