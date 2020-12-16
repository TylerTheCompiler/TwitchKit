//
//  LegacyGetChatEmoticonsBySetRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// Gets all chat emoticons (not including their images) in one or more specified sets.
public struct LegacyGetChatEmoticonsBySetRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias AppToken = IncompatibleAccessToken
    
    public struct ResponseBody: Decodable {
        
        /// The returned list of emotes.
        public let emoticonSets: [Int: [LegacyEmote]]
        
        public init(from decoder: Decoder) throws {
            struct StringCodingKeys: CodingKey {
                let stringValue: String
                let intValue: Int?
                
                init(stringValue: String) {
                    self.stringValue = stringValue
                    self.intValue = Int(stringValue)
                }
                
                init(intValue: Int) {
                    self.stringValue = intValue.description
                    self.intValue = intValue
                }
            }
            
            struct CodeAndId: Decodable {
                let code: String
                let id: Int
            }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let emoteSetsContainer = try container.nestedContainer(keyedBy: StringCodingKeys.self,
                                                                   forKey: .emoticonSets)
            var emoteSets = [Int: [LegacyEmote]]()
            for key in emoteSetsContainer.allKeys {
                guard let emoteSetId = key.intValue else { continue }
                let emotes = try emoteSetsContainer.decode([CodeAndId].self, forKey: key).map {
                    LegacyEmote(code: $0.code, emoticonSet: emoteSetId, id: $0.id)
                }
                
                emoteSets[emoteSetId] = emotes
            }
            
            emoticonSets = emoteSets
        }
        
        private enum CodingKeys: String, CodingKey {
            case emoticonSets
        }
    }
    
    public enum QueryParamKey: String {
        case emoteSets = "emotesets"
    }
    
    public let apiVersion: APIVersion = .kraken
    public let path = "/chat/emoticon_images"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Get Chat Emoticons By Set legacy request.
    ///
    /// - Parameter emoteSets: Specifies the set(s) of emoticons to retrieve.
    public init(emoteSets: [Int]) {
        queryParams = [
            (.emoteSets, emoteSets.map(\.description).joined(separator: ","))
        ]
    }
}
