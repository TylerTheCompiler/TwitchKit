//
//  CreatePollRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 8/27/21.
//

/// Creates a poll for a specific Twitch channel.
public struct CreatePollRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    
    public struct RequestBody: Encodable {
        
        /// Represents a choice in a Twitch chat poll.
        internal struct PollChoice: Encodable {
            
            /// Text displayed for the choice.
            ///
            /// Maximum: 25 characters.
            internal var title: String
            
            /// Creates a new Poll Choice with the given title.
            ///
            /// - Parameter title: Text displayed for the choice. Maximum: 25 characters.
            internal init(title: String) {
                self.title = title
            }
        }
        
        /// The broadcaster running polls. Must match the user ID in the user OAuth token.
        internal var broadcasterId: String = ""
        
        /// Question displayed for the poll.
        ///
        /// Maximum: 60 characters.
        internal var title: String
        
        /// Array of the poll choices.
        ///
        /// Minimum: 2 choices. Maximum: 5 choices.
        internal var choices: [PollChoice]
        
        /// Total duration for the poll (in seconds).
        ///
        /// Minimum: 15. Maximum: 1800.
        internal var duration: Int
        
        /// Indicates if Bits can be used for voting.
        ///
        /// Default: false
        internal var bitsVotingEnabled: Bool?
        
        /// Number of Bits required to vote once with Bits.
        ///
        /// Minimum: 0. Maximum: 10000.
        internal var bitsPerVote: Int?

        /// Indicates if Channel Points can be used for voting.
        ///
        /// Default: false
        internal var channelPointsVotingEnabled: Bool?
        
        /// Number of Channel Points required to vote once with Channel Points.
        ///
        /// Minimum: 0. Maximum: 1000000.
        internal var channelPointsPerVote: Int?
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
    
    public let method: HTTPMethod = .post
    public let path = "/polls"
    public private(set) var body: RequestBody?
    
    /// Creates a new Create Poll request.
    ///
    /// - Parameters:
    ///   - title: Question displayed for the poll. Maximum: 60 characters.
    ///   - choices: Array of the poll choices. Each element is a string representing the text displayed for one choice.
    ///              Minimum: 2 choices. Maximum: 5 choices. Default: `["Yes", "No"]`.
    ///   - duration: Total duration for the poll (in seconds). Minimum: 15. Maximum: 1800. Default: 180 (3 minutes).
    ///   - bitsVotingEnabled: Indicates if Bits can be used for voting. Default: false
    ///   - bitsPerVote: Number of Bits required to vote once with Bits. Minimum: 0. Maximum: 10000.
    ///   - channelPointsVotingEnabled: Indicates if Channel Points can be used for voting. Default: false
    ///   - channelPointsPerVote: Number of Channel Points required to vote once with Channel Points.
    ///                           Minimum: 0. Maximum: 1000000.
    public init(title: String,
                choices: [String] = ["Yes", "No"],
                duration: Int = 180,
                bitsVotingEnabled: Bool? = nil,
                bitsPerVote: Int? = nil,
                channelPointsVotingEnabled: Bool? = nil,
                channelPointsPerVote: Int? = nil) {
        body = .init(
            title: title,
            choices: choices.map { .init(title: $0) },
            duration: duration,
            bitsVotingEnabled: bitsVotingEnabled,
            bitsPerVote: bitsPerVote,
            channelPointsVotingEnabled: channelPointsVotingEnabled,
            channelPointsPerVote: channelPointsPerVote
        )
    }
    
    public mutating func update(with userId: String) {
        body?.broadcasterId = userId
    }
}
