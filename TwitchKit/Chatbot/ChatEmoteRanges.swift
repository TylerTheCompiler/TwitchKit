//
//  ChatEmoteRanges.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

/// Information to replace text in the message with emote images.
public struct ChatEmoteRanges {
    
    /// Information to replace text in the message with emote images. This can be empty.
    public let ranges: [ChatEmote: [ClosedRange<String.Index>]]
    
    /// A convenience accessor subscript.
    ///
    /// This is the same as saying:
    ///
    ///     self.ranges[emote]
    ///
    /// - Parameter emote: The emote to retrieve string ranges for.
    public subscript(emote: ChatEmote) -> [ClosedRange<String.Index>]? {
        ranges[emote]
    }
    
    internal init(rawValue: String, message: String) {
        var emotes = [ChatEmote: [ClosedRange<String.Index>]]()
        for emoteString in rawValue.components(separatedBy: "/") {
            let emoteRangesKeyValuePair = emoteString.components(separatedBy: ":")
            guard emoteRangesKeyValuePair.count == 2 else { continue }
            
            let emoteId = emoteRangesKeyValuePair[0]
            let emoteRangesString = emoteRangesKeyValuePair[1]
            var emoteRanges = [ClosedRange<String.Index>]()
            
            for emoteRangeString in emoteRangesString.components(separatedBy: ",") {
                let emoteRangeKeyValuePair = emoteRangeString.components(separatedBy: "-")
                guard emoteRangeKeyValuePair.count == 2,
                      let emoteRangeLowerBound = Int(emoteRangeKeyValuePair[0]),
                      let emoteRangeUpperBound = Int(emoteRangeKeyValuePair[1]),
                      emoteRangeLowerBound < emoteRangeUpperBound,
                      emoteRangeLowerBound < message.count,
                      emoteRangeUpperBound < message.count else {
                    continue
                }
                
                let emoteRange = ClosedRange(
                    uncheckedBounds: (
                        message.index(message.startIndex, offsetBy: emoteRangeLowerBound),
                        message.index(message.startIndex, offsetBy: emoteRangeUpperBound)
                    )
                )
                
                emoteRanges.append(emoteRange)
            }
            
            if !emoteRanges.isEmpty {
                emotes[ChatEmote(identifier: emoteId)] = emoteRanges
            }
        }
        
        ranges = emotes
    }
}
