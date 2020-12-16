//
//  Cheermote.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// An animated emote.
public struct Cheermote: Decodable {
    
    /// Metadata of a single tier of a cheermote.
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
        
        /// Minimum number of bits needed to be used to hit the given tier of emote.
        public let minBits: Int
        
        /// ID of the emote tier. Possible tiers are: 1, 100, 500, 1000, 5000, 10k, or 100k.
        public let id: String
        
        /// Hex code for the color associated with the bits of that tier. Grey, Purple, Teal, Blue, or Red color to
        /// match the base bit type.
        public let color: String
        
        /// Structure containing both animated and static image sets, sorted by light and dark.
        public let images: Images
        
        /// Indicates whether or not emote information is accessible to users.
        public let canCheer: Bool
        
        /// Indicates whether or not Twitch hides the emote from the bits card.
        public let showInBitsCard: Bool
    }
    
    /// The type of cheermote.
    public enum CheermoteType: String, Decodable {
        case globalFirstParty = "global_first_party"
        case globalThirdParty = "global_third_party"
        case channelCustom = "channel_custom"
        case displayOnly = "display_only"
        case sponsored
    }
    
    /// The cheermote's textual prefix as used in chat. E.g. if the cheer is "Cheer100", then the `prefix` is "Cheer".
    public let prefix: String
    
    /// An array of Cheermotes with their metadata.
    public let tiers: [Tier]
    
    /// The type of cheermote.
    public let type: CheermoteType
    
    /// Order of the emotes as shown in the bits card, in ascending order.
    public let order: Int
    
    /// The date when this Cheermote was last updated.
    @InternetDate
    public private(set) var lastUpdated: Date
    
    /// Whether or not this emote provides a charity contribution match during charity campaigns.
    public let isCharitable: Bool
}
