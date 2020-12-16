//
//  HTTPErrorResponse.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/9/20.
//

/// A response of an HTTP or HTTPS request that may contain an error and possibly an `HTTPURLResponse`.
public struct HTTPErrorResponse {
    
    /// If an error occurred during the HTTP/HTTPS request, this should be set to that error.
    /// Otherwise, if no error occurred, this should be set to nil.
    public let error: Error?
    
    /// If there was an HTTP or HTTPS request made, this should contain the URL response of that request.
    public let httpURLResponse: HTTPURLResponse?
    
    /// Creates a new `HTTPErrorResponse` from the given error and HTTP URL response.
    ///
    /// - Parameters:
    ///   - error: An error.
    ///   - httpURLResponse: An HTTP URL response.
    public init(_ error: Error? = nil, _ httpURLResponse: HTTPURLResponse? = nil) {
        self.error = error
        self.httpURLResponse = httpURLResponse
    }
}
