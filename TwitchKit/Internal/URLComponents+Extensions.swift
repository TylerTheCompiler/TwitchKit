//
//  URLComponents+Extensions.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

extension URLComponents {
    internal func firstQueryValue(for name: String) -> String? {
        queryItems?.first { $0.name == name }?.value
    }
    
    internal func queryValues(for name: String) -> [String] {
        queryItems?.filter { $0.name == name }.compactMap(\.value) ?? []
    }
    
    internal mutating func setQueryValue(_ value: String?, for name: String) {
        queryItems = queryItems ?? []
        queryItems?.removeAll { $0.name == name }
        value.flatMap { queryItems?.append(.init(name: name, value: $0)) }
    }
    
    internal mutating func setQueryValues(_ values: [String], for name: String) {
        queryItems = queryItems ?? []
        queryItems?.removeAll { $0.name == name }
        queryItems?.append(contentsOf: values.map { .init(name: name, value: $0) })
    }
    
    internal mutating func addQueryValue(_ value: String?, for name: String) {
        queryItems = queryItems ?? []
        value.flatMap { queryItems?.append(.init(name: name, value: $0)) }
    }
    
    internal mutating func addQueryValues(_ values: [String], for name: String) {
        queryItems = queryItems ?? []
        queryItems?.append(contentsOf: values.map { .init(name: name, value: $0) })
    }
    
    internal var urlRequest: URLRequest {
        // swiftlint:disable:next force_unwrapping
        .init(url: url!)
    }
}
