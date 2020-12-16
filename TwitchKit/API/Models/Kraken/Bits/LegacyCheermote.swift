//
//  LegacyCheermote.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/8/20.
//

/// <#Description#>
public struct LegacyCheermote: Decodable {
    
    /// <#Description#>
    public enum Background: String, Decodable {
        case light
        case dark
    }
    
    /// <#Description#>
    public enum Scale: String, Decodable {
        case x1 = "1"
        case x1_5 = "1.5"
        case x2 = "2"
        case x3 = "3"
        case x4 = "4"
    }
    
    /// <#Description#>
    public enum State: String, Decodable {
        case `static`
        case animated
    }
    
    /// <#Description#>
    public struct Tier: Decodable {
        
        /// Structure containing both animated and static image sets, sorted by light and dark.
        public struct Images: Decodable {
            
            /// Structure containing animated and static image URLs for a cheermote.
            public struct ImageSet: Decodable {
                
                /// Structure containing a set of URLs for different sizes of a cheermote.
                public struct ImageURLs: Decodable {
                    
                    /// The URL for an emote of scale 1.
                    @SafeURL
                    public private(set) var x1: URL?
                    
                    /// The URL for an emote of scale 1.5.
                    @SafeURL
                    public private(set) var x1_5: URL?
                    
                    /// The URL for an emote of scale 2.
                    @SafeURL
                    public private(set) var x2: URL?
                    
                    /// The URL for an emote of scale 3.
                    @SafeURL
                    public private(set) var x3: URL?
                    
                    /// The URL for an emote of scale 4.
                    @SafeURL
                    public private(set) var x4: URL?
                    
                    private enum CodingKeys: String, CodingKey {
                        case x1 = "1"
                        case x1_5 = "1.5"
                        case x2 = "2"
                        case x3 = "3"
                        case x4 = "4"
                    }
                }
                
                /// The set of URLs for the animated version of the cheermote.
                public let animated: ImageURLs
                
                /// The set of URLs for the non-animated version of the cheermote.
                public let `static`: ImageURLs
            }
            
            /// The animated and static set of URLs for the dark version of the cheermote.
            public let dark: ImageSet
            
            /// The animated and static set of URLs for the light version of the cheermote.
            public let light: ImageSet
        }
        
        /// <#Description#>
        public let id: String
        
        /// <#Description#>
        public let color: String
        
        /// <#Description#>
        public let images: Images
        
        /// <#Description#>
        public let minBits: Int
        
        /// <#Description#>
        public let canCheer: Bool
    }
    
    /// <#Description#>
    public let backgrounds: [Background]
    
    /// <#Description#>
    public let prefix: String
    
    /// <#Description#>
    public let scales: [Scale]
    
    /// <#Description#>
    public let states: [State]
    
    /// <#Description#>
    public let tiers: [Tier]
}
