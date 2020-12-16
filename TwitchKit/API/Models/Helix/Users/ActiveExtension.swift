//
//  ActiveExtension.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Metadata about an active Extension.
public struct ActiveExtension: Equatable, Decodable {
    
    /// Additional information about an active Extension.
    public struct Information: Equatable, Decodable {
        public static func == (lhs: Information, rhs: Information) -> Bool {
            guard lhs.id == rhs.id,
                  lhs.version == rhs.version,
                  lhs.name == rhs.name else {
                return false
            }
            
            if lhs.coordinates == nil, rhs.coordinates == nil {
                return true
            }
            
            if let leftCoords = lhs.coordinates, let rightCoords = rhs.coordinates {
                return leftCoords == rightCoords
            }
            
            return false
        }
        
        /// ID of the extension.
        public let id: String
        
        /// Version of the extension.
        public let version: String
        
        /// Name of the extension.
        public let name: String
        
        /// X and Y coordinates of the placement of a video-component extension.
        public let coordinates: (x: Int, y: Int)?
        
        internal init(id: String, version: String, name: String, coordinates: (x: Int, y: Int)?) {
            self.id = id
            self.version = version
            self.name = name
            self.coordinates = coordinates
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .identifier)
            version = try container.decode(String.self, forKey: .version)
            name = try container.decode(String.self, forKey: .name)
            
            let xCoord = try container.decodeIfPresent(Int.self, forKey: .xCoord)
            let yCoord = try container.decodeIfPresent(Int.self, forKey: .yCoord)
            
            if let xCoord = xCoord, let yCoord = yCoord {
                coordinates = (xCoord, yCoord)
            } else {
                coordinates = nil
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case version
            case name
            case xCoord = "x"
            case yCoord = "y"
        }
    }
    
    /// Whether the extension is active or not. If false, `information` is nil.
    public let isActive: Bool
    
    /// Information about an active extension. Nil if the extension is not active.
    public let information: Information?
    
    internal init(isActive: Bool, information: Information?) {
        self.isActive = isActive
        self.information = information
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        
        if isActive {
            information = try Information(from: decoder)
        } else {
            information = nil
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case isActive = "active"
    }
}
