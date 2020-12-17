//
//  User.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A Twitch user.
public struct User: Decodable {
    
    /// The type of user.
    public enum UserType: String, Decodable {
        case staff
        case admin
        case globalMod = "global_mod"
        case normal = ""
    }
    
    /// The type of broadcaster the user is.
    public enum BroadcasterType: String, Decodable {
        case partner
        case affiliate
        case normal = ""
    }
    
    /// User’s ID.
    public let id: String
    
    /// User’s login name.
    public let login: String
    
    /// User’s display name.
    public let displayName: String
    
    /// User’s type.
    public let type: UserType
    
    /// User’s broadcaster type.
    public let broadcasterType: BroadcasterType
    
    /// User’s channel description.
    public let description: String
    
    /// URL of the user’s profile image.
    @SafeURL
    public private(set) var profileImageUrl: URL?
    
    /// URL of the user’s offline image.
    @SafeURL
    public private(set) var offlineImageUrl: URL?
    
    /// Total number of views of the user’s channel.
    public let viewCount: Int
    
    /// User’s email address. Returned if the request includes the `.userReadEmail` `Scope`.
    public let email: String?
    
    /// Date when the user was created.
    @OptionalInternetDateWithOptionalFractionalSeconds
    public private(set) var createdAt: Date?
}
