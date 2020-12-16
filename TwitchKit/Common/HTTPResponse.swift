//
//  HTTPResponse.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/9/20.
//

/// A response of an HTTP or HTTPS request that contains both a result and possibly an `HTTPURLResponse`.
public struct HTTPResponse<Success, Failure> where Failure: Error {
    
    /// The result of the request.
    public let result: Result<Success, Failure>
    
    /// If there was an HTTP or HTTPS request made, this should contain the URL response of that request.
    public let httpURLResponse: HTTPURLResponse?
    
    /// Creates a new `HTTPResponse` from a `Result` and an `HTTPURLResponse`.
    ///
    /// - Parameters:
    ///   - result: The result of the response.
    ///   - httpURLResponse: The `HTTPURLResponse` of the response, or nil if there wasn't one. Default: nil.
    public init(_ result: Result<Success, Failure>, _ httpURLResponse: HTTPURLResponse? = nil) {
        self.result = result
        self.httpURLResponse = httpURLResponse
    }
    
    /// Creates a successful `HTTPResponse` from the given `success` value.
    ///
    /// - Parameters:
    ///   - success: The success instance of the successful response.
    ///   - httpURLResponse: The `HTTPURLResponse` of the response, or nil if there wasn't one. Default: nil.
    public init(_ success: Success, _ httpURLResponse: HTTPURLResponse? = nil) {
        self.init(.success(success), httpURLResponse)
    }
    
    /// Creates a failed `HTTPResponse` from the given `error`.
    ///
    /// - Parameters:
    ///   - error: An error that occurred.
    ///   - httpURLResponse: The `HTTPURLResponse` of the response, or nil if there wasn't one. Default: nil.
    public init(_ error: Failure, _ httpURLResponse: HTTPURLResponse? = nil) {
        self.init(.failure(error), httpURLResponse)
    }
}
