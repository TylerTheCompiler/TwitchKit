//
//  JSONCoding+Extensions.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

extension JSONDecoder {
    internal static var snakeCaseToCamelCase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

extension JSONEncoder {
    internal static var camelCaseToSnakeCase: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

extension JSONDecoder {
    func decode<T>(_ type: T.Type, from data: Data?) throws -> T where T: Decodable {
        try decode(type, from: data ?? Data())
    }
}
