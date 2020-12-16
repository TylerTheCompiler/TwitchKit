//
//  ChatColor.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

/// A color for a username in Twitch chat.
public enum ChatColor: RawRepresentable {
    case blue
    case blueViolet
    case cadetBlue
    case chocolate
    case coral
    case dodgerBlue
    case firebrick
    case goldenRod
    case green
    case hotPink
    case orangeRed
    case red
    case seaGreen
    case springGreen
    case yellowGreen
    case other(hex: String)
    
    public var rawValue: String {
        switch self {
        case .blue: return "Blue"
        case .blueViolet: return "BlueViolet"
        case .cadetBlue: return "CadetBlue"
        case .chocolate: return "Chocolate"
        case .coral: return "Coral"
        case .dodgerBlue: return "DodgerBlue"
        case .firebrick: return "Firebrick"
        case .goldenRod: return "GoldenRod"
        case .green: return "Green"
        case .hotPink: return "HotPink"
        case .orangeRed: return "OrangeRed"
        case .red: return "Red"
        case .seaGreen: return "SeaGreen"
        case .springGreen: return "SpringGreen"
        case .yellowGreen: return "YellowGreen"
        case .other(let hex):
            return "#\(hex.trimmingCharacters(in: .init(charactersIn: "# ")))"
        }
    }
    
    public init(rawValue: String) {
        switch rawValue.lowercased() {
        case Self.blue.rawValue.lowercased(): self = .blue
        case Self.blueViolet.rawValue.lowercased(): self = .blueViolet
        case Self.cadetBlue.rawValue.lowercased(): self = .cadetBlue
        case Self.chocolate.rawValue.lowercased(): self = .chocolate
        case Self.coral.rawValue.lowercased(): self = .coral
        case Self.dodgerBlue.rawValue.lowercased(): self = .dodgerBlue
        case Self.firebrick.rawValue.lowercased(): self = .firebrick
        case Self.goldenRod.rawValue.lowercased(): self = .goldenRod
        case Self.green.rawValue.lowercased(): self = .green
        case Self.hotPink.rawValue.lowercased(): self = .hotPink
        case Self.orangeRed.rawValue.lowercased(): self = .orangeRed
        case Self.red.rawValue.lowercased(): self = .red
        case Self.seaGreen.rawValue.lowercased(): self = .seaGreen
        case Self.springGreen.rawValue.lowercased(): self = .springGreen
        case Self.yellowGreen.rawValue.lowercased(): self = .yellowGreen
        default: self = .other(hex: rawValue)
        }
    }
}
