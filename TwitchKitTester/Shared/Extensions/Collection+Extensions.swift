//
//  Collection+Extensions.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 11/19/20.
//

enum CollectionError<C: Collection>: Error {
    case indexOutOfBounds(collection: C, index: C.Index)
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
    func element(at index: Index) throws -> Element {
        guard let element = self[safe: index] else {
            throw CollectionError.indexOutOfBounds(collection: self, index: index)
        }
        
        return element
    }
}
