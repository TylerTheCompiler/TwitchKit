//
//  ChatMessage.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

/// A message received in Twitch chat.
public enum ChatMessage {
    
    // Membership
    case join(UserChannelMembership)
    case part(UserChannelMembership)
    
    // Commands
    case plainMessage(PlainMessage)
    case whisper(Whisper)
    case host(HostMode)
    case unhost(UnhostMode)
    case notice(Notice)
    case clearChat(ClearChat)
    case clearMessage(ClearMessage)
    case globalUserState(GlobalUserState)
    case userState(UserState)
    case roomState(RoomState)
    case userNotice(UserNotice)
    
    // Other
    case ping
    case reconnect
    case nameReply(NameReply)
    case endOfNamesList(EndOfNamesList)
    case unhandled(rawValue: String)
    
    public struct NameReply {
        public let channel: String
        public let usernames: [String]
    }
    
    public struct EndOfNamesList {
        public let channel: String
    }
    
    public init(rawValue: String) {
        // swiftlint:disable:previous cyclomatic_complexity function_body_length
        guard !rawValue.isEmpty else {
            self = .unhandled(rawValue: rawValue)
            return
        }
        
        let message: String
        let extraMessageInfo: String?
        if rawValue.hasPrefix("@"),
           let atSignIndex = rawValue.firstIndex(of: "@"),
           case let indexAfterAtSign = rawValue.index(after: atSignIndex) {
            let rangeOfSpaceColon = rawValue.range(of: " :")
            let extraMessageInfoEndIndex = rangeOfSpaceColon?.lowerBound ?? rawValue.endIndex
            extraMessageInfo = String(rawValue[indexAfterAtSign..<extraMessageInfoEndIndex])
            if let rangeOfSpaceColon = rangeOfSpaceColon {
                message = String(rawValue[rawValue.index(before: rangeOfSpaceColon.upperBound)...])
            } else {
                message = ""
            }
        } else {
            extraMessageInfo = nil
            message = rawValue
        }
        
        let nick: String?
        let user: String?
        let host: String?
        let commandIndex: String.Index
        if message.hasPrefix(":"),
           let colonIndex = message.firstIndex(of: ":"),
           case let indexAfterColon = message.index(after: colonIndex),
           let spaceIndex = message.firstIndex(of: " ") {
            commandIndex = message[message.index(after: spaceIndex)...].firstIndex { $0 != " " } ?? message.startIndex
            let prefix = String(message[indexAfterColon..<spaceIndex])
            
            let exclamationIndex = prefix.firstIndex(of: "!")
            let atSignIndex = prefix.firstIndex(of: "@")
            
            if exclamationIndex == nil, atSignIndex == nil, prefix.contains(".") {
                nick = nil
                user = nil
                host = nil
            } else {
                if let exclamationIndex = exclamationIndex {
                    nick = String(prefix[..<exclamationIndex])
                    
                    if let atSignIndex = atSignIndex {
                        user = String(prefix[prefix.index(after: exclamationIndex)..<atSignIndex])
                        host = String(prefix[prefix.index(after: atSignIndex)...])
                    } else {
                        user = String(prefix[prefix.index(after: exclamationIndex)...])
                        host = nil
                    }
                } else {
                    nick = prefix
                    user = nil
                    host = nil
                }
            }
        } else {
            nick = nil
            user = nil
            host = nil
            commandIndex = message.startIndex
        }
        
        let commandAndParams = String(message[commandIndex...])
        let spaceIndex = commandAndParams.firstIndex(of: " ") ?? commandAndParams.endIndex
        let command = String(commandAndParams[..<spaceIndex])
        var params = [String]()
        if let spaceIndex = commandAndParams.firstIndex(of: " ") {
            let paramsString = String(commandAndParams[commandAndParams.index(after: spaceIndex)...])
            if let trailingParamDelimeterRange = paramsString.range(of: " :") {
                let trailingParamStartIndex = trailingParamDelimeterRange.upperBound
                let middleParamsString = paramsString[...trailingParamDelimeterRange.lowerBound]
                params.append(contentsOf: middleParamsString.components(separatedBy: " "))
                params.append(String(paramsString[trailingParamStartIndex...]))
            } else {
                params.append(contentsOf: paramsString.components(separatedBy: " "))
            }
            
            params.removeAll(where: \.isEmpty)
        }
        
        var tagValues = [String: String]()
        if let extraMessageInfo = extraMessageInfo {
            let extraComponents = extraMessageInfo.components(separatedBy: ";")
            for component in extraComponents {
                let keyValueComponents = component.components(separatedBy: "=")
                guard keyValueComponents.count == 2 else { continue }
                let key = keyValueComponents[0]
                let value = keyValueComponents[1]
                let unescapedValue = value.unescapedIRCMessageTagValue
                tagValues[key] = unescapedValue
            }
        }
        
        tagValues["channel"] = params.first.flatMap({ $0.hasPrefix("#") ? String($0.dropFirst()) : nil })
        
        let secondParam = params.count >= 2 ? params[1] : nil
        tagValues["message"] = secondParam
        
        do {
            switch command {
            case "PING":
                self = .ping
                
            case "JOIN", "PART":
                tagValues["nick"] = nick
                tagValues["user"] = user
                tagValues["host"] = host
                
                if command == "JOIN" {
                    self = try .join(.init(dictionary: tagValues))
                } else {
                    self = try .part(.init(dictionary: tagValues))
                }
                
            case "HOSTTARGET":
                guard let channel = tagValues["channel"],
                      let secondParam = secondParam else {
                    throw ChatMessageError.unhandledMessage
                }
                
                let channelToHostAndNumberOfViewers = secondParam.components(separatedBy: " ")
                let channelToHost = channelToHostAndNumberOfViewers[0]
                let numberOfViewers: Int?
                if channelToHostAndNumberOfViewers.count >= 2 {
                    numberOfViewers = Int(channelToHostAndNumberOfViewers[1])
                } else {
                    numberOfViewers = nil
                }
                
                if channelToHost != "-" {
                    self = .host(.init(
                        channel: channelToHost,
                        hostingChannel: channel,
                        numberOfViewers: numberOfViewers
                    ))
                } else {
                    self = .unhost(.init(
                        hostingChannel: channel,
                        numberOfViewers: numberOfViewers
                    ))
                }
                
            case "NOTICE":
                self = try .notice(.init(dictionary: tagValues))
                
            case "RECONNECT":
                self = .reconnect
                
            case "CLEARCHAT":
                self = try .clearChat(.init(dictionary: tagValues))
                
            case "CLEARMSG":
                self = try .clearMessage(.init(dictionary: tagValues))
                
            case "GLOBALUSERSTATE":
                self = .globalUserState(.init(dictionary: tagValues))
                
            case "PRIVMSG":
                tagValues["user"] = user
                self = try .plainMessage(.init(dictionary: tagValues))
                
            case "WHISPER":
                tagValues["user"] = user
                self = try .whisper(.init(dictionary: tagValues))
                
            case "USERSTATE":
                self = try .userState(.init(dictionary: tagValues))
                
            case "ROOMSTATE":
                self = try .roomState(.init(dictionary: tagValues))
                
            case "USERNOTICE":
                self = try .userNotice(.init(dictionary: tagValues))
                
            case "353": // RPL_NAMREPLY
                guard params.count == 4,
                      params[1] == "=",
                      params[2].hasPrefix("#") else {
                    throw ChatMessageError.unhandledMessage
                }
                
                let channel = String(params[2].dropFirst())
                let usernames = params[3].components(separatedBy: " ")
                
                let nameReply = NameReply(channel: channel, usernames: usernames)
                self = .nameReply(nameReply)
                
            case "366": // RPL_ENDOFNAMES
                guard params.count == 3,
                      params[1].hasPrefix("#") else {
                    throw ChatMessageError.unhandledMessage
                }
                
                let channel = String(params[1].dropFirst())
                
                let endOfNamesList = EndOfNamesList(channel: channel)
                self = .endOfNamesList(endOfNamesList)
                
            default:
                throw ChatMessageError.unhandledMessage
            }
        } catch {
            self = .unhandled(rawValue: rawValue)
        }
    }
    
    internal enum ChatMessageError: Error {
        case unhandledMessage
    }
}
