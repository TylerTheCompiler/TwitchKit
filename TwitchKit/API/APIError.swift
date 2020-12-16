//
//  APIError.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// Returned from the API when an error occurs.
public struct APIError: Error, Equatable, Decodable {
    
    /// The error that occurred.
    public let error: String?
    
    /// The status code of the error that occurred.
    public let status: Int
    
    /// A human-readable message explaining the error that occurred.
    public let message: String
}
