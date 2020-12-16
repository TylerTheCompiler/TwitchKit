//
//  LegacyUpdateVideoRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Updates information about a specified video that was already created.
public struct LegacyUpdateVideoRequest: APIRequest {
    public typealias AppToken = IncompatibleAccessToken
    public typealias ResponseBody = LegacyVideo
    
    public enum QueryParamKey: String {
        case title
        case description
        case game
        case language
        case tagList = "tag_list"
    }
    
    public let apiVersion: APIVersion = .kraken
    public let method: HTTPMethod = .put
    public let path: String
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Update Video legacy request.
    ///
    /// - Parameters:
    ///   - videoId: The video ID of the video to update.
    ///   - title: Title of the video. Maximum 100 characters.
    ///   - description: Short description of the video.
    ///   - game: Name of the game in the video.
    ///   - language: Language of the video (for example, "en").
    ///   - tags: Tags describing the video. Maximum: 100 characters per tag, 500 characters for the entire list.
    public init(videoId: String,
                title: String? = nil,
                description: String? = nil,
                game: String? = nil,
                language: String? = nil,
                tags: [String] = []) {
        path = "/videos/\(videoId)"
        queryParams = [
            (.title, title),
            (.description, description),
            (.game, game),
            (.language, language),
            (.tagList, tags.joined(separator: ","))
        ]
    }
}
