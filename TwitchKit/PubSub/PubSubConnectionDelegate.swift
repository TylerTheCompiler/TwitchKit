//
//  PubSubConnectionDelegate.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

/// A type that can respond to events emitted by a `PubSubConnection`.
public protocol PubSubConnectionDelegate: AnyObject {
    
    /// Informs the delegate that the connection received a message.
    ///
    /// - Parameters:
    ///   - connection: The `PubSubConnection` that received the message.
    ///   - message: The message that was received by the connection.
    func pubSubConnection(_ connection: PubSub.Connection, didReceive message: PubSub.Message)
    
    /// Informs the delegate that the connection received some data.
    ///
    /// - Parameters:
    ///   - connection: The `PubSubConnection` that received the data.
    ///   - data: The data that was received by the connection.
    func pubSubConnection(_ connection: PubSub.Connection, didReceive data: Data)
    
    /// Informs the delegate that the connection failed to receive data.
    ///
    /// - Parameters:
    ///   - connection: The `PubSubConnection` that failed to receive data.
    ///   - error: The error that occurred when the connection tried to receive data.
    func pubSubConnection(_ connection: PubSub.Connection, didFailToReceiveDataWith error: Error)
    
    /// Informs the delegate that the connection sent a raw message string.
    ///
    /// - Parameters:
    ///   - connection: The `PubSubConnection` that sent the message.
    ///   - message: The message that the connection sent.
    func pubSubConnection(_ connection: PubSub.Connection, didSend message: String)
    
    /// Informs the delegate that the connection failed to send data.
    ///
    /// - Parameters:
    ///   - connection: The `PubSubConnection` that failed to send data.
    ///   - error: The error that occurred when the connection tried to send data.
    func pubSubConnection(_ connection: PubSub.Connection, didFailToSendDataWith error: Error)
}

// MARK: - Empty Default Implementations

extension PubSubConnectionDelegate {
    
    /// Default implementation. Does nothing.
    ///
    /// - Parameters:
    ///   - connection: Unused.
    ///   - message: Unused.
    public func pubSubConnection(_ connection: PubSub.Connection, didReceive message: PubSub.Message) {}
    
    /// Default implementation. Does nothing.
    ///
    /// - Parameters:
    ///   - connection: Unused.
    ///   - data: Unused.
    public func pubSubConnection(_ connection: PubSub.Connection, didReceive data: Data) {}
    
    /// Default implementation. Does nothing.
    ///
    /// - Parameters:
    ///   - connection: Unused.
    ///   - error: Unused.
    public func pubSubConnection(_ connection: PubSub.Connection, didFailToReceiveDataWith error: Error) {}
    
    /// Default implementation. Does nothing.
    ///
    /// - Parameters:
    ///   - connection: Unused.
    ///   - message: Unused.
    public func pubSubConnection(_ connection: PubSub.Connection, didSend message: String) {}
    
    /// Default implementation. Does nothing.
    ///
    /// - Parameters:
    ///   - connection: Unused.
    ///   - error: Unused.
    public func pubSubConnection(_ connection: PubSub.Connection, didFailToSendDataWith error: Error) {}
}
