//
//  LegacyGetTeamRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets a specified team object.
public struct LegacyGetTeamRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyTeam
    
    public let apiVersion: APIVersion = .kraken
    public let path: String
    
    /// Creates a new Get Team legacy request.
    ///
    /// - Parameter teamName: The name of the team to get.
    public init(teamName: String) {
        path = "/teams/\(teamName)"
    }
}
