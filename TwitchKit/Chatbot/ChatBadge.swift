//
//  ChatBadge.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

/// A Twitch chat badge.
public enum ChatBadge: RawRepresentable {
    case admin(version: Int)
    case bits(version: Int)
    case broadcaster(version: Int)
    case globalMod(version: Int)
    case moderator(version: Int)
    case subscriber(version: Int)
    case staff(version: Int)
    case turbo(version: Int)
    case other(name: String, version: Int)
    
    /// The raw name of the badge.
    public var name: String {
        switch self {
        case .admin: return "admin"
        case .bits: return "bits"
        case .broadcaster: return "broadcaster"
        case .globalMod: return "global_mod"
        case .moderator: return "moderator"
        case .subscriber: return "subscriber"
        case .staff: return "staff"
        case .turbo: return "turbo"
        case .other(let name, _): return name
        }
    }
    
    /// The version of the badge.
    public var version: Int {
        switch self {
        case .admin(let version),
             .bits(let version),
             .broadcaster(let version),
             .globalMod(let version),
             .moderator(let version),
             .subscriber(let version),
             .staff(let version),
             .turbo(let version),
             .other(_, let version):
            return version
        }
    }
    
    public var rawValue: String {
        "\(name)/\(version)"
    }
    
    public init?(rawValue: String) {
        let components = rawValue.components(separatedBy: "/")
        guard components.count == 2, let version = Int(components[1]) else { return nil }
        let name = components[0]
        self.init(name: name, version: version)
    }
    
    /// Creates a `ChatBadge` instance from the given name and version.
    ///
    /// - Parameters:
    ///   - name: The raw name of the chat badge.
    ///   - version: The version of the chat badge.
    public init(name: String, version: Int) {
        switch name {
        case "admin": self = .admin(version: version)
        case "bits": self = .bits(version: version)
        case "broadcaster": self = .broadcaster(version: version)
        case "global_mod": self = .globalMod(version: version)
        case "moderator": self = .moderator(version: version)
        case "subscriber": self = .subscriber(version: version)
        case "staff": self = .staff(version: version)
        case "turbo": self = .turbo(version: version)
        default: self = .other(name: name, version: version)
        }
    }
}
