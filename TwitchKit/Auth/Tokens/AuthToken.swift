//
//  AuthToken.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// A type that represents a token used for authorization.
///
/// Types that are auth tokens:
///   * `UserAccessToken`
///   * `RefreshToken`
///   * `AppAccessToken`
///   * `UnncecessaryAccessToken`
public protocol AuthToken: Equatable, Codable {}
