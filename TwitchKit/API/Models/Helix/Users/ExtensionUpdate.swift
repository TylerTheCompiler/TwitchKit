//
//  ExtensionUpdate.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// Object containing the properties to update an Extension with.
public struct ExtensionUpdate: Equatable, Encodable {
    
    /// Whether the extension should be active or not.
    public let isActive: Bool?
    
    /// The ID of the extension.
    public let id: String?
    
    /// The extension's version.
    public let version: String?
    
    /// Creates an `ExtensionUpdate`.
    ///
    /// - Parameters:
    ///   - isActive: Whether the extension should be active or not.
    ///   - id: The ID of the extension.
    ///   - version: The extension's version.
    public init(isActive: Bool? = nil, id: String? = nil, version: String? = nil) {
        self.isActive = isActive
        self.id = id
        self.version = version
    }
    
    private enum CodingKeys: String, CodingKey {
        case isActive = "active"
        case id
        case version
    }
}
