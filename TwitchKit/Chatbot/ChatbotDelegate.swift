//
//  ChatbotDelegate.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/13/20.
//

/// Adopters of this protocol can be set as a `Chatbot`'s `delegate` and be notified of various chatbot events.
///
/// All of these methods are optional, but it is highly recommended to at least implement `chatbot(_:didReceive:)`
/// so that you can respond to incoming messages.
///
/// You can also opt to just not implement this delegate at all and just subclass `Chatbot` instead, and then
/// override methods like `didReceive(message:)` to respond to messages that way.
public protocol ChatbotDelegate: AnyObject {
    
    /// Called upon receiving incoming raw message strings right before they are processed.
    ///
    /// - Parameters:
    ///   - chatbot: The `Chatbot` that received the message strings.
    ///   - messageStrings: The raw message strings that the chatbot received and will attempt to process.
    func chatbot(_ chatbot: Chatbot, willProcess messageStrings: [String])
    
    /// Called after successfully processing a raw message string into a `ChatMessage`.
    ///
    /// Use this method to respond to incoming chat messages.
    ///
    /// - Parameters:
    ///   - chatbot: The `Chatbot` that received and processed the message.
    ///   - message: The `ChatMessage` that the chatbot processed from a raw message string.
    func chatbot(_ chatbot: Chatbot, didReceive message: ChatMessage)
    
    /// Called after processing all incoming raw message strings.
    ///
    /// - Parameters:
    ///   - chatbot: The `Chatbot` that received the message strings.
    ///   - messageStrings: The raw message strings that the chatbot received and attempted to process.
    func chatbot(_ chatbot: Chatbot, didProcess messageStrings: [String])
    
    /// Called by a chatbot if there is an error when receiving data from its internal connection.
    ///
    /// - Parameters:
    ///   - chatbot: The `Chatbot` that received the error.
    ///   - error: The error received.
    func chatbot(_ chatbot: Chatbot, didFailToReceiveDataWith error: Error)
    
    /// Called after a chatbot successfully sends a message.
    ///
    /// - Parameters:
    ///   - chatbot: The `Chatbot` that sent the message.
    ///   - message: The message that was sent.
    func chatbot(_ chatbot: Chatbot, didSend message: String)
    
    /// Called by a chatbot if there is an error when sending data across its internal connection.
    ///
    /// - Parameters:
    ///   - chatbot: The `Chatbot` that received the error.
    ///   - message: The message that failed to be sent.
    ///   - error: The error received.
    func chatbot(_ chatbot: Chatbot, didFailToSend message: String, with error: Error)
}

// MARK: - Empty Default Implementations

extension ChatbotDelegate {
    public func chatbot(_ chatbot: Chatbot, willProcess messageStrings: [String]) {}
    public func chatbot(_ chatbot: Chatbot, didReceive message: ChatMessage) {}
    public func chatbot(_ chatbot: Chatbot, didProcess messageStrings: [String]) {}
    public func chatbot(_ chatbot: Chatbot, didFailToReceiveDataWith error: Error) {}
    public func chatbot(_ chatbot: Chatbot, didSend message: String) {}
    public func chatbot(_ chatbot: Chatbot, didFailToSend message: String, with error: Error) {}
}
