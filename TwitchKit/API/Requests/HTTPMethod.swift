//
//  HTTPMethod.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// An enum that wraps the HTTP methods GET, POST, PUT, DELETE and PATCH.
public enum HTTPMethod: String {
    
    /// The GET HTTP method.
    case get = "GET"
    
    /// The POST HTTP method.
    case post = "POST"
    
    /// The PUT HTTP method.
    case put = "PUT"
    
    /// The DELETE HTTP method.
    case delete = "DELETE"
    
    /// The PATCH HTTP method.
    case patch = "PATCH"
}
