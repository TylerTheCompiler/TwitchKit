//
//  EndPollRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

/// Ends a poll that is currently active.
public struct EndPollRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public enum Status: String, Encodable {
        
        /// End the poll manually, but allow it to be viewed publicly.
        case terminated = "TERMINATED"
        
        /// End the poll manually and do not allow it to be viewed publicly.
        case archived = "ARCHIVED"
    }
    
    public struct RequestBody: Encodable {
        
        /// The broadcaster running polls. Must match the user ID in the user OAuth token.
        internal var broadcasterId: String = ""
        
        /// ID of the poll.
        internal let id: String
        
        /// The poll status to be set.
        internal let status: Status
    }
    
    public struct ResponseBody: Decodable {
        
        /// The poll that was created.
        public let poll: Poll
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard let poll = try container.decode([Poll].self, forKey: .poll).first else {
                throw DecodingError.valueNotFound(
                    Poll.self,
                    .init(
                        codingPath: container.codingPath,
                        debugDescription: "Expected to decode Poll, but array of Polls was empty."
                    )
                )
            }
            
            self.poll = poll
        }
        
        private enum CodingKeys: String, CodingKey {
            case poll = "data"
        }
    }
    
    public let method: HTTPMethod = .patch
    public let path = "/polls"
    public private(set) var body: RequestBody?
    
    /// Creates a new End Poll request.
    ///
    /// - Parameters:
    ///   - pollId: ID of the poll to end.
    ///   - status: The poll status to be set. Set to `.terminated` to end the poll manually, but allow it to be
    ///             viewed publicly. Set to `.archived` to end the poll manually and to not allow it to be viewed
    ///             publicly. Default: `.terminated`.
    public init(pollId: String, status: Status = .terminated) {
        body = .init(id: pollId, status: status)
    }
    
    public mutating func update(with userId: String) {
        body?.broadcasterId = userId
    }
}
