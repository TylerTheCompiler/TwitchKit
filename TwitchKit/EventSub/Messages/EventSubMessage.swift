//
//  EventSubMessage.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/11/20.
//

import CommonCrypto

extension EventSub {
    
    /// <#Description#>
    public enum Message {
        
        /// <#Description#>
        public enum Error: Swift.Error {
            
            /// <#Description#>
            case unexpectedFormat
            
            /// <#Description#>
            case invalidTimestamp
            
            /// <#Description#>
            case duplicateMessageId(String)
            
            /// <#Description#>
            case invalidSignature
            
            /// <#Description#>
            case unknownMessageType(String?)
        }
        
        /// <#Description#>
        case webhookCallbackVerification(WebhookCallbackVerification)
        
        /// <#Description#>
        case notification(Notification)
        
        /// <#Description#>
        ///
        /// - Parameters:
        ///   - headers: <#headers description#>
        ///   - bodyDataString: <#bodyDataString description#>
        ///   - secret: <#secret description#>
        ///   - maxMessageAgeInMinutes: <#maxMessageAgeInMinutes description#>
        ///   - isDuplicateHandler: <#isDuplicateHandler description#>
        /// - Throws: <#description#>
        public init(headers: [String: String],
                    bodyDataString: String,
                    secret: String,
                    maxMessageAgeInMinutes: Int? = nil,
                    isDuplicateHandler: ((_ messageId: String) -> Bool)? = nil) throws {
            let headers = Dictionary(headers.map { ($0.key.lowercased(), $0.value) }, uniquingKeysWith: { $1 })
            guard let signature = headers["twitch-eventsub-message-signature"],
                  let messageId = headers["twitch-eventsub-message-id"],
                  let timestampString = headers["twitch-eventsub-message-timestamp"],
                  let messageType = headers["twitch-eventsub-message-type"] else {
                throw Error.unexpectedFormat
            }
            
            if let maxMessageAgeInMinutes = maxMessageAgeInMinutes {
                let earliestAllowedTimestamp = Date() - (60.0 * TimeInterval(maxMessageAgeInMinutes))
                guard let timestamp = InternetDateConvertingStrategy.date(from: timestampString),
                      timestamp >= earliestAllowedTimestamp else {
                    throw Error.invalidTimestamp
                }
            }
            
            let bodyData = Data(bodyDataString.utf8)
            
            if let isDuplicateHandler = isDuplicateHandler {
                guard isDuplicateHandler(messageId) == false else {
                    throw Error.duplicateMessageId(messageId)
                }
            }
            
            try Self.verify(signature: signature,
                            messageId: messageId,
                            messageTimestamp: timestampString,
                            rawBodyData: bodyData,
                            secret: secret)
            
            let decoder = JSONDecoder.snakeCaseToCamelCase
            
            switch messageType {
            case "webhook_callback_verification":
                let verification = try decoder.decode(WebhookCallbackVerification.self, from: bodyData)
                self = .webhookCallbackVerification(verification)
            
            case "notification":
                self = try .notification(decoder.decode(Notification.self, from: bodyData))
            
            default:
                throw Error.unknownMessageType(messageType)
            }
        }
        
        /// <#Description#>
        ///
        /// - Parameters:
        ///   - rawHTTPPostMessageString: <#rawHTTPPostMessageString description#>
        ///   - secret: <#secret description#>
        ///   - maxMessageAgeInMinutes: <#maxMessageAgeInMinutes description#>
        ///   - isDuplicateHandler: <#isDuplicateHandler description#>
        /// - Throws: <#description#>
        public init(rawHTTPPostMessageString: String,
                    secret: String,
                    maxMessageAgeInMinutes: Int? = nil,
                    isDuplicateHandler: ((_ messageId: String) -> Bool)? = nil) throws {
            let lines = rawHTTPPostMessageString.components(separatedBy: "\r\n")
            
            guard let firstLine = lines.first,
                  !firstLine.isEmpty,
                  case let firstLineComponents = firstLine.components(separatedBy: " "),
                  firstLineComponents.count == 3,
                  firstLineComponents[0] == "POST",
                  firstLineComponents[1] == "/",
                  firstLineComponents[2] == "HTTP/1.1",
                  let indexOfBlankLine = lines.firstIndex(of: ""),
                  lines.count >= indexOfBlankLine + 1 else {
                throw Error.unexpectedFormat
            }
            
            let headerStrings = Array(lines[1..<indexOfBlankLine])
            let bodyDataString = lines[indexOfBlankLine + 1]
            
            let headers = Dictionary(headerStrings.compactMap { headerString in
                guard let firstIndexOfColon = headerString.firstIndex(of: ":") else { return nil }
                return (key: headerString[..<firstIndexOfColon].trimmingCharacters(in: .whitespacesAndNewlines),
                        value: headerString[headerString.index(after: firstIndexOfColon)...]
                            .trimmingCharacters(in: .whitespacesAndNewlines))
            } as [(key: String, value: String)], uniquingKeysWith: { $1 })
            
            try self.init(headers: headers,
                          bodyDataString: bodyDataString,
                          secret: secret,
                          maxMessageAgeInMinutes: maxMessageAgeInMinutes,
                          isDuplicateHandler: isDuplicateHandler)
        }
        
        private static func verify(signature: String,
                                   messageId: String,
                                   messageTimestamp: String,
                                   rawBodyData: Data,
                                   secret: String) throws {
            let key = [UInt8](secret.utf8)
            let message = [UInt8](Data(messageId.utf8) + Data(messageTimestamp.utf8) + rawBodyData)
            var result = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, message, message.count, &result)
            
            let resultHex = result.reduce("") { $0 + String(format: "%02x", $1) }
            let expectedSignatureHeader = "sha256=" + resultHex

            guard signature == expectedSignatureHeader else { throw Error.invalidSignature }
        }
    }
}
