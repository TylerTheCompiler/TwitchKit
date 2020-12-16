//
//  DispatchQueue.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension DispatchQueue {
    internal convenience init(for type: Any.Type,
                              name: String,
                              qos: DispatchQoS = .unspecified,
                              attributes: Attributes = [],
                              autoreleaseFrequency: AutoreleaseFrequency = .inherit,
                              target: DispatchQueue? = nil) {
        let nameForType = String(reflecting: type).components(separatedBy: ".").dropFirst().joined(separator: ".")
        let bundleIdentifier = Self.getBundleIdHandler() ?? "<unknown-bundle>"
        self.init(label: "\(bundleIdentifier).TwitchKit.\(nameForType).\(name)",
                  qos: qos,
                  attributes: attributes,
                  autoreleaseFrequency: autoreleaseFrequency,
                  target: target)
    }
    
    // For unit testing
    internal static var getBundleIdHandler = { Bundle.main.bundleIdentifier }
}
