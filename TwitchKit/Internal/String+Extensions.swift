//
//  String+Extensions.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/3/20.
//

// MARK: Base64 URL Encoding/Decoding

extension StringProtocol {
    internal var base64URLDecodedData: Data? {
        let substituted = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let padded = substituted + String(repeating: "=", count: (4 - substituted.count % 4) % 4)
        
        return Data(base64Encoded: padded)
    }
    
    internal var base64URLDecoded: String? {
        base64URLDecodedData.flatMap { String(data: $0, encoding: .utf8) }
    }
}

extension Data {
    internal var base64URLEncodedString: String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// MARK: IRC Escaping

extension String {
    internal var escapedIRCMessageTagValue: String {
        var copy = self
        copy = copy.replacingOccurrences(of: "\\", with: "\\\\")
        copy = copy.replacingOccurrences(of: "\n", with: "\\n")
        copy = copy.replacingOccurrences(of: "\r", with: "\\r")
        copy = copy.replacingOccurrences(of: " ", with: "\\s")
        copy = copy.replacingOccurrences(of: ";", with: "\\:")
        return copy
    }
    
    internal var unescapedIRCMessageTagValue: String {
        var copy = self
        copy = copy.replacingOccurrences(of: "\\:", with: ";")
        copy = copy.replacingOccurrences(of: "\\s", with: " ")
        copy = copy.replacingOccurrences(of: "\\r", with: "\r")
        copy = copy.replacingOccurrences(of: "\\n", with: "\n")
        copy = copy.replacingOccurrences(of: "\\\\", with: "\\")
        return copy
    }
}
