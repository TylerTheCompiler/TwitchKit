//
//  Optional+Extensions.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/11/20.
//

extension Optional where Wrapped: Collection {
    internal var isEmpty: Bool {
        switch self {
        case .some(let collection):
            return collection.isEmpty
            
        case .none:
            return true
        }
    }
}
