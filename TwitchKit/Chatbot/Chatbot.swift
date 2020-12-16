//
//  Chatbot.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/13/20.
//

import Network

/// A Twitch chatbot.
open class Chatbot {
    
    /// A closure called when the Chatbot completes an asynchronous task.
    public typealias Completion = (_ error: Swift.Error?) -> Void
    
    /// A closure called when the Chatbot completes multiple asynchronous tasks, possibly in multiple channels.
    public typealias MultiCompletion = ([(channel: String, error: Swift.Error)]) -> Void
    
    /// An error type related to Twitch chat tasks.
    public enum Error: Swift.Error {
        
        /// A Twitch chatbot error that means a task was expecting some data,
        /// but the data was either nil or empty.
        case missingData
        
        /// A Twitch chatbot error that means something went wrong with receiving messages.
        /// You should disconnect and reconnect the chatbot if you receive this message.
        case receivedMessageCompleteFlag
        
        /// A Twitch chatbot error that means a task was expecting valid data,
        /// but the data was not in the expected format or was otherwise invalid in some way.
        case invalidData(Data)
    }
    
    /// The auth session to use to get the user access token when connecting the chatbot to Twitch.
    public enum AuthSession {
        
        /// A client auth session.
        case client(ClientAuthSession)
        
        /// A server auth session.
        case server(ServerUserAuthSession)
    }
    
    /// The username of the chatbot.
    public let username: String
    
    /// The auth session to use to get the user access token when connecting the chatbot to Twitch.
    public let authSession: AuthSession
    
    /// An object that is notified of chatbot events.
    open weak var delegate: ChatbotDelegate?
    
    /// The queue on which to call all delegate callbacks.
    /// If nil, the delegate callbacks are called on the internal queue that events are received on.
    open var delegateQueue: DispatchQueue?
    
    /// The current list of channels that the chatbot is in.
    ///
    /// This is updated automatically as the chatbot joins/leaves channels.
    @ReaderWriterValue(Chatbot.self, propertyName: "joinedChannels")
    public private(set) var joinedChannels = [String]()
    
    /// The current list of users by channel.
    ///
    /// The keys are channel names (lowercased). This is updated automatically by the chatbot as the chatbot
    /// joins/leaves channels and as users join/leave the channels that the chatbot is in.
    @ReaderWriterValue(Chatbot.self, propertyName: "currentUsers")
    public private(set) var currentUsers = [String: Set<String>]()
    
    /// Whether the chatbot should automatically try to reconnect to Twitch after receiving a RECONNECT message.
    /// Default: true.
    @ReaderWriterValue(Chatbot.self, propertyName: "shouldHandleRedirectsAutomatically")
    public var shouldHandleRedirectsAutomatically = true
    
    /// Whether the chatbot is currently attempting to reconnect to Twitch.
    public var isAttemptingReconnect: Bool {
        reconnectIteration != nil
    }
    
    /// Creates a chatbot.
    ///
    /// - Parameters:
    ///   - username: Username of the chatbot.
    ///   - authSession: The auth session to use to get the user access token when connecting the chatbot to Twitch.
    ///   - delegate: An object to receive chatbot event callbacks. May be set after initialization.
    ///   - delegateQueue: The queue on which to receive delegate callbacks. Default: the main queue.
    public init(username: String,
                authSession: AuthSession,
                delegate: ChatbotDelegate? = nil,
                delegateQueue: DispatchQueue? = .main) {
        self.username = username
        self.authSession = authSession
        self.delegate = delegate
        self.delegateQueue = delegateQueue
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: - Connection Methods
    
    /// Connects the chatbot to Twitch. You must call this before you can have the bot interact with channels.
    open func connect(completion: ((HTTPErrorResponse) -> Void)? = nil) {
        func connect(accessToken: ValidatedUserAccessToken) {
            disconnect()
            connection = .init(host: "irc.chat.twitch.tv", port: 6697, using: .tls)
            connection?.stateUpdateHandler = { [weak self] state in
                switch state {
                case .failed, .cancelled, .waiting(.posix(.ETIMEDOUT)):
                    guard let reconnectIteration = self?.reconnectIteration else {
                        self?.channelsToRejoin = []
                        break
                    }
                    
                    self?.attemptReconnect(withIteration: reconnectIteration + 1)
                    
                default:
                    break
                }
            }
            
            connection?.start(queue: connectionQueue)
            
            read()
            send(command: "CAP REQ :twitch.tv/membership")
            send(command: "CAP REQ :twitch.tv/tags")
            send(command: "CAP REQ :twitch.tv/commands")
            send(command: "PASS oauth:\(accessToken.stringValue)")
            send(command: "NICK \(username.lowercased())")
        }
        
        switch authSession {
        case .client(let session):
            session.getAccessToken { response in
                switch response.result {
                case .success((let validatedAccessToken, _)):
                    connect(accessToken: validatedAccessToken)
                    completion?(.init(nil, response.httpURLResponse))
                    
                case .failure(let error):
                    self.reconnectIteration = nil
                    self.channelsToRejoin = []
                    completion?(.init(error, response.httpURLResponse))
                }
            }
            
        case .server(let session):
            session.getAccessToken { response in
                switch response.result {
                case .success(let validatedAccessToken):
                    connect(accessToken: validatedAccessToken)
                    completion?(.init(nil, response.httpURLResponse))
                    
                case .failure(let error):
                    self.reconnectIteration = nil
                    self.channelsToRejoin = []
                    completion?(.init(error, response.httpURLResponse))
                }
            }
        }
    }
    
    /// Disconnects the chatbot from Twitch.
    open func disconnect() {
        leaveAllChannels()
        joinedChannels.removeAll()
        currentUsers.removeAll()
        connection?.cancel()
        connection = nil
    }
    
    /// Cancels the currently ongoing reconnection attempt, if there is one.
    ///
    /// Does nothing if the chatbot is not currently attempting to reconnect to Twitch.
    open func cancelReconnect() {
        guard isAttemptingReconnect else { return }
        reconnectIteration = nil
        channelsToRejoin = []
    }
    
    // MARK: - Channel Membership Methods
    
    /// Joins a channel.
    ///
    /// - Parameters:
    ///   - channel: The name of a channel to join.
    ///   - completion: A closure to be called when the join succeeds or fails.
    open func join(channel: String, completion: Completion? = nil) {
        let lowercasedChannel = channel.lowercased()
        usersBeingAggregated[channel] = []
        send(command: "JOIN #\(lowercasedChannel)") { [weak self] error in
            defer { completion?(error) }
            guard error == nil else { return }
            self?.joinedChannels.removeAll { $0 == lowercasedChannel }
            self?.joinedChannels.append(lowercasedChannel)
        }
    }
    
    /// Joins the specified channels.
    ///
    /// - Parameters:
    ///   - channels: The names of the channels to join.
    ///   - completion: A closure to be called when the join succeeds or fails.
    open func join(channels: [String], completion: MultiCompletion? = nil) {
        performMultiple(
            items: channels,
            queueName: "joinMultipleChannelsQueue",
            function: { channel, singleCompletion in
                join(channel: channel) { singleCompletion(channel, $0) }
            },
            completion: completion
        )
    }
    
    /// Leaves a channel.
    ///
    /// - Parameters:
    ///   - channel: The name of a channel to leave.
    ///   - completion: A closure to be called when the leave succeeds or fails.
    open func leave(channel: String, completion: Completion? = nil) {
        let lowercasedChannel = channel.lowercased()
        send(command: "PART #\(lowercasedChannel)") { [weak self] error in
            defer { completion?(error) }
            guard error == nil else { return }
            self?.joinedChannels.removeAll { $0 == lowercasedChannel }
            self?.currentUsers[channel] = []
            self?.usersBeingAggregated[channel] = []
        }
    }
    
    /// Leaves the specified channels.
    ///
    /// - Parameters:
    ///   - channels: The names of the channels to leave.
    ///   - completion: A closure to be called when all leaves have completed.
    open func leave(channels: [String], completion: MultiCompletion? = nil) {
        performMultiple(
            items: channels,
            queueName: "leaveMultipleChannelsQueue",
            function: { channel, singleCompletion in
                leave(channel: channel) { singleCompletion(channel, $0) }
            },
            completion: completion
        )
    }
    
    /// Leaves all joined channels.
    ///
    /// - Parameter completion: A closure to be called when all leaves have completed.
    open func leaveAllChannels(completion: MultiCompletion? = nil) {
        leave(channels: joinedChannels, completion: completion)
    }
    
    // MARK: - Sending messages to a channel
    
    /// Sends a message to a channel.
    ///
    /// - Parameters:
    ///   - message: The message to send.
    ///   - channel: The name of a channel to send the message to.
    ///   - completion: A closure to be called when the send succeeds or fails.
    open func send(message: String, to channel: String, completion: Completion? = nil) {
        send(command: "PRIVMSG #\(channel.lowercased()) :\(message)", completion: completion)
    }
    
    /// Sends multiple messages to a channel.
    ///
    /// - Parameters:
    ///   - messages: The messages to send.
    ///   - channel: The name of a channel to send the messages to.
    ///   - completion: A closure to be called when the send succeeds or fails.
    open func send(messages: [String], to channel: String, completion: MultiCompletion? = nil) {
        performMultiple(
            items: messages,
            queueName: "sendMultipleMessagesQueue",
            function: { message, singleCompletion in
                send(message: message, to: channel) { singleCompletion(channel, $0) }
            },
            completion: completion
        )
    }
    
    // MARK: - Sending commands to a channel
    
    /// Enables or disables emote-only mode in a channel.
    ///
    /// - Parameters:
    ///   - enable: Whether to enable or disable emote-only mode in `channel`.
    ///   - channel: The name of a channel to enable/disable emote-only mode in.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func emoteOnly(enable: Bool, in channel: String, completion: Completion? = nil) {
        send(message: enable ? "/emoteonly" : "/emoteonlyoff", to: channel, completion: completion)
    }
    
    /// Enables or disables slow mode in a channel.
    ///
    /// - Parameters:
    ///   - enable: Whether to enable or disable slow mode in `channel`.
    ///   - channel: The name of a channel to enable/disable slow mode in.
    ///   - duration: When `enable` is `true`, the duration a user must wait between sending chat messages.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func slowMode(enable: Bool, in channel: String, duration: Int? = nil, completion: Completion? = nil) {
        var message: String
        if enable {
            message = "/slow"
            if let duration = duration, duration > 0 {
                message += " \(duration)"
            }
        } else {
            message = "/slowoff"
        }
        
        send(message: message, to: channel, completion: completion)
    }
    
    /// Enables or disables unique-chat mode in a channel.
    ///
    /// - Parameters:
    ///   - enable: Whether to enable or disable unique-chat mode in `channel`.
    ///   - channel: The name of a channel to enable/disable unique-chat mode in.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func uniqueChatMode(enable: Bool, in channel: String, completion: Completion? = nil) {
        send(message: enable ? "/uniquechat" : "/uniquechatoff", to: channel, completion: completion)
    }
    
    /// Enables or disables followers-only mode in a channel.
    ///
    /// - Parameters:
    ///   - enable: Whether to enable or disable followers-only mode in `channel`.
    ///   - channel: The name of a channel in which to enable/disable followers-only mode.
    ///   - duration: When `enable` is `true`, the duration a user must be following `channel` before being
    ///               able to chat. Default: nil
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func followersOnly(enable: Bool,
                            in channel: String,
                            duration: ChatDuration? = nil,
                            completion: Completion? = nil) {
        var message: String
        if enable {
            message = "/followers"
            if let duration = duration {
                message += " " + duration.rawValue
            }
        } else {
            message = "/followersoff"
        }
        
        send(message: message, to: channel, completion: completion)
    }
    
    /// Enables or disables subscribers-only mode in a channel.
    ///
    /// - Parameters:
    ///   - enable: Whether to enable or disable subscribers-only mode in `channel`.
    ///   - channel: The name of a channel in which to enable/disable subscribers-only mode.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func subscribersOnly(enable: Bool, in channel: String, completion: Completion? = nil) {
        send(message: enable ? "/subscribers" : "/subscribersoff", to: channel, completion: completion)
    }
    
    /// Clears all chat in a channel.
    ///
    /// - Parameters:
    ///   - channel: The name of a channel to clear chat in.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func clearChat(in channel: String, completion: Completion? = nil) {
        send(message: "/clear", to: channel, completion: completion)
    }
    
    /// Removes a single message from a channel.
    ///
    /// - Parameters:
    ///   - messageId: UUID of the message to delete.
    ///   - channel: The name of the channel in which to delete the message.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func deleteMessage(messageId: String, in channel: String, completion: Completion? = nil) {
        send(message: "/delete \(messageId)", to: channel, completion: completion)
    }
    
    /// Time out a user in chat.
    ///
    /// - Parameters:
    ///   - user: The username of the user who you want to time out.
    ///   - channel: The name of a channel in which to time out `user`.
    ///   - duration: An optional duration that specifies for how long to time out `user`.
    ///   - reason: An optional reason string to show to the user why they were timed out.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func timeout(user: String,
                      in channel: String,
                      duration: ChatDuration? = nil,
                      reason: String? = nil,
                      completion: Completion? = nil) {
        var message = "/timeout \(user.lowercased())"
        if let duration = duration {
            message += " " + duration.rawValue
        }
        
        if let reason = reason, !reason.isEmpty {
            message += " " + reason
        }
        
        send(message: message, to: channel, completion: completion)
    }
    
    /// Removes a timeout from a user in a channel.
    ///
    /// - Parameters:
    ///   - user: The username of a user to remove a timeout for.
    ///   - channel: The name of a channel in which to remove the timeout for `user`.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func untimeout(user: String, in channel: String, completion: Completion? = nil) {
        send(message: "/untimeout \(user.lowercased())", to: channel, completion: completion)
    }
    
    /// Permanently bans a user from chatting in a channel.
    ///
    /// - Parameters:
    ///   - user: The username of the user to ban.
    ///   - channel: The channel in which to ban `user`.
    ///   - reason: An optional reason string to show to the user why they were banned.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func ban(user: String, in channel: String, reason: String? = nil, completion: Completion? = nil) {
        var message = "/ban \(user.lowercased())"
        if let reason = reason, !reason.isEmpty {
            message += " " + reason
        }
        
        send(message: message, to: channel, completion: completion)
    }
    
    /// Unbans or untimeouts a user in a channel.
    ///
    /// - Parameters:
    ///   - user: The username of the user to unban.
    ///   - channel: The channel in which to unban `user`.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func unban(user: String, in channel: String, completion: Completion? = nil) {
        send(message: "/unban \(user.lowercased())", to: channel, completion: completion)
    }
    
    /// Starts hosting a channel from another channel.
    ///
    /// - Parameters:
    ///   - channel: The name of the channel to host (their channel).
    ///   - hostingChannel: The name of the channel doing the hosting (your channel).
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func host(channel: String, from hostingChannel: String, completion: Completion? = nil) {
        send(message: "/host \(channel.lowercased())", to: hostingChannel, completion: completion)
    }
    
    /// Stops host mode in a channel.
    ///
    /// - Parameters:
    ///   - channel: The name of the channel you want to turn off host mode for (your channel).
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func unhost(in channel: String, completion: Completion? = nil) {
        send(message: "/unhost", to: channel, completion: completion)
    }
    
    /// Starts a raid from your channel to another channel.
    ///
    /// - Parameters:
    ///   - channel: The name of the channel to raid (their channel).
    ///   - hostingChannel: The name of the channel doing the raiding (your channel).
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func raid(channel: String, from hostingChannel: String, completion: Completion? = nil) {
        send(message: "/raid \(channel.lowercased())", to: hostingChannel, completion: completion)
    }
    
    /// Cancels an in-progress raid in a channel.
    ///
    /// - Parameters:
    ///   - channel: The name of the channel you want to cancel the raid in (your channel).
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func unraid(in channel: String, completion: Completion? = nil) {
        send(message: "/unraid", to: channel, completion: completion)
    }
    
    /// Adds a stream marker at the current timestamp for a channel. Only valid when `channel` is live.
    ///
    /// - Parameters:
    ///   - channel: The name of a channel to create the stream marker for.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func createMarker(in channel: String, completion: Completion? = nil) {
        send(message: "/marker", to: channel, completion: completion)
    }
    
    /// Grants moderator status to a user.
    ///
    /// - Parameters:
    ///   - user: The username of the user to grant moderator status to.
    ///   - channel: The name of the channel in which to grant `user` moderator status.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func mod(user: String, in channel: String, completion: Completion? = nil) {
        send(message: "/mod \(user.lowercased())", to: channel, completion: completion)
    }
    
    /// Revokes moderator status from a user.
    ///
    /// - Parameters:
    ///   - user: The username of the user to revoke moderator status from.
    ///   - channel: The name of the channel in which to revoke `user`'s moderator status.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func unmod(user: String, in channel: String, completion: Completion? = nil) {
        send(message: "/unmod \(user.lowercased())", to: channel, completion: completion)
    }
    
    /// Grants VIP status to a user.
    ///
    /// - Parameters:
    ///   - user: The username of the user to grant VIP status to.
    ///   - channel: The name of the channel in which to grant `user` VIP status.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func vip(user: String, in channel: String, completion: Completion? = nil) {
        send(message: "/vip \(user.lowercased())", to: channel, completion: completion)
    }
    
    /// Revokes VIP status from a user.
    ///
    /// - Parameters:
    ///   - user: The username of the user to revoke VIP status from.
    ///   - channel: The name of the channel in which to revoke `user`'s VIP status.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func unvip(user: String, in channel: String, completion: Completion? = nil) {
        send(message: "/unvip \(user.lowercased())", to: channel, completion: completion)
    }
    
    /// Changes the bot's username color.
    ///
    /// - Important: Even though a channel must be specified, this change affects the bot's username color
    ///              across all of Twitch!
    ///
    /// - Parameters:
    ///   - color: The color to change the bot's username color to.
    ///   - channel: A name of a channel to send the color change command to. Note that even though a channel must be
    ///              specified, this change affects the bot's username color across all of Twitch!
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func changeUsernameColor(to color: ChatColor, in channel: String, completion: Completion? = nil) {
        send(message: "/color \(color.rawValue)", to: channel, completion: completion)
    }
    
    /// Displays a list of moderators for the given channel.
    ///
    /// The channel should send a `Notice` message containing the list of moderators shortly after calling this.
    ///
    /// - Parameters:
    ///   - channel: The name of a channel to list moderators for.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func listModerators(in channel: String, completion: Completion? = nil) {
        send(message: "/mods", to: channel, completion: completion)
    }
    
    /// Displays a list of VIPs for the given channel.
    ///
    /// The channel should send a `Notice` message containing the list of VIPs shortly after calling this.
    ///
    /// - Parameters:
    ///   - channel: The name of a channel to list VIPs for.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func listVIPs(in channel: String, completion: Completion? = nil) {
        send(message: "/vips", to: channel, completion: completion)
    }
    
    /// Privately messages a user with a given message.
    ///
    /// This feature is only available to known or verified bots. Request to increase your bot's status to known
    /// or verified [here](https://dev.twitch.tv/limit-increase).
    ///
    /// - Parameters:
    ///   - user: The username of the user to send the whisper to.
    ///   - message: The message to send to the user.
    ///   - completion: A closure to be called when the command succeeds or fails.
    open func whisper(user: String, message: String, completion: Completion? = nil) {
        send(message: "/w \(user.lowercased()) \(message)", to: user.lowercased(), completion: completion)
    }
    
    // MARK: - Override Points
    
    /// Override point for subclasses to handle incoming raw message strings before they are processed.
    ///
    /// This is called before `didReceive(message:)` and `didProcess(messageStrings:)`.
    ///
    /// The default implementation does nothing.
    ///
    /// - Parameter messageStrings: The raw message strings that were received at once by the chatbot.
    open func willProcess(messageStrings: [String]) {
        // To be overridden
    }
    
    /// Override point for subclasses to handle individual incoming processed messages.
    ///
    /// This is called after `willProcess(messageStrings:)` and is called for each message string that is processed
    /// into a `ChatMessage` (except for `PING` messages, as `PING`s are handled internally by the chatbot).
    ///
    /// The default implementation does nothing.
    ///
    /// - Parameter message: A message received by the chatbot.
    open func didReceive(message: ChatMessage) {
        // To be overridden
    }
    
    /// Override point for subclasses to handle incoming raw message strings after they have been processed.
    ///
    /// This is called after `didReceive(message:)` has been called for all message strings that could be processed
    /// into `ChatMessage`s  (except for `PING` messages, as `PING`s are handled internally by the chatbot).
    ///
    /// The default implementation does nothing.
    ///
    /// - Parameter messageStrings: The raw message strings that were received at once by the chatbot.
    open func didProcess(messageStrings: [String]) {
        // To be overridden
    }
    
    /// Override point for subclasses to handle errors when attempting to read data from the connection.
    ///
    /// - Parameter error: The error received upon attempting to read data. Possible error types include
    ///                    `Chatbot.Error` and `NWError` (from the `Network` iOS framework).
    open func didFailToReceiveData(with error: Swift.Error) {
        // To be overridden
    }
    
    /// Override point for subclasses to be notified when the chatbot sends a command.
    ///
    /// - Parameter command: The raw command string sent by the bot.
    open func didSend(command: String) {
        // To be overridden
    }
    
    /// Override point for subclasses to handle network errors when attempting to send commands to the connection.
    ///
    /// - Parameters:
    ///   - command: The command that the chatbot attempted to send.
    ///   - error: The `NWError` received upon attempting to send the command.
    open func didFailToSend(command: String, with error: NWError) {
        // To be overridden
    }
    
    // MARK: - Private
    
    private func read() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1<<16) { [weak self] data, _, complete, error in
            guard let self = self else { return }
            
            defer { self.read() }
            
            if let error = error {
                self.didFailToReceiveData(with: error)
                self.tryExecutingOnDelegateQueue {
                    self.delegate?.chatbot(self, didFailToReceiveDataWith: error)
                }
                
                return
            }
            
            if complete {
                let error = Error.receivedMessageCompleteFlag
                self.didFailToReceiveData(with: error)
                self.tryExecutingOnDelegateQueue {
                    self.delegate?.chatbot(self, didFailToReceiveDataWith: error)
                }
                
                return
            }
            
            guard let data = data else {
                let error = Error.missingData
                self.didFailToReceiveData(with: error)
                self.tryExecutingOnDelegateQueue {
                    self.delegate?.chatbot(self, didFailToReceiveDataWith: error)
                }
                
                return
            }
            
            guard let lines = String(data: data, encoding: .utf8) else {
                let error = Error.invalidData(data)
                self.didFailToReceiveData(with: error)
                self.tryExecutingOnDelegateQueue {
                    self.delegate?.chatbot(self, didFailToReceiveDataWith: error)
                }
                
                return
            }
            
            let messages = lines.components(separatedBy: "\r\n").filter { !$0.isEmpty }
            self.willProcess(messageStrings: messages)
            self.tryExecutingOnDelegateQueue {
                self.delegate?.chatbot(self, willProcess: messages)
            }
            
            for message in messages {
                self.process(message: message)
            }
            
            self.didProcess(messageStrings: messages)
            self.tryExecutingOnDelegateQueue {
                self.delegate?.chatbot(self, didProcess: messages)
            }
        }
    }
    
    private func send(command: String, completion: ((Swift.Error?) -> Void)? = nil) {
        connection?.send(content: Data("\(command)\r\n".utf8), completion: .contentProcessed({ [weak self] error in
            if let completion = completion {
                if let delegateQueue = self?.delegateQueue {
                    delegateQueue.async { completion(error) }
                } else {
                    completion(error)
                }
            }
            
            guard let self = self else { return }
            
            if let error = error {
                self.didFailToSend(command: command, with: error)
                self.tryExecutingOnDelegateQueue {
                    self.delegate?.chatbot(self, didFailToSend: command, with: error)
                }
            } else {
                // Don't want to notify on PONG as that should be entirely private (unless there was an error).
                guard command != "PONG" else { return }
                self.didSend(command: command)
                self.tryExecutingOnDelegateQueue {
                    self.delegate?.chatbot(self, didSend: command)
                }
            }
        }))
        
        read()
    }
    
    private func process(message: String) {
        let processedMessage = ChatMessage(rawValue: message)
        
        switch processedMessage {
        case .ping:
            send(command: "PONG")
            return // Don't want to notify on PONGs as those should be handled entirely internally
            
        case .reconnect:
            attemptReconnect()
            
        case .globalUserState:
            guard isAttemptingReconnect else { break }
            reconnectIteration = nil
            let channelsToRejoin = self.channelsToRejoin
            self.channelsToRejoin = []
            join(channels: channelsToRejoin)
            
        case .nameReply(let nameReply): // 353 RPL_NAMREPLY
            usersBeingAggregated[nameReply.channel, default: []].formUnion(nameReply.usernames)
            
        case .endOfNamesList(let endOfNamesList): // 366 RPL_ENDOFNAMES
            currentUsers[endOfNamesList.channel] = usersBeingAggregated[endOfNamesList.channel]
            usersBeingAggregated[endOfNamesList.channel] = []
            
        case .join(let userChannelMembership):
            guard let user = userChannelMembership.user else { break }
            currentUsers[userChannelMembership.channel, default: []].insert(user)
            
        case .part(let userChannelMembership):
            guard let user = userChannelMembership.user else { break }
            currentUsers[userChannelMembership.channel]?.remove(user)
            
        default:
            break
        }
        
        didReceive(message: processedMessage)
        
        tryExecutingOnDelegateQueue {
            self.delegate?.chatbot(self, didReceive: processedMessage)
        }
    }
    
    private func tryExecutingOnDelegateQueue(_ closure: @escaping () -> Void) {
        if let delegateQueue = delegateQueue {
            delegateQueue.async(execute: closure)
        } else {
            closure()
        }
    }
    
    private func performMultiple<T>(items: [T],
                                    queueName: String,
                                    function: (_ item: T,
                                               _ completion: @escaping (_ channel: String,
                                                                        _ error: Swift.Error?) -> Void) -> Void,
                                    completion: MultiCompletion?) {
        let group = DispatchGroup()
        let queue = DispatchQueue(for: Self.self, name: queueName)
        var errors = [(channel: String, error: Swift.Error)]()
        
        for item in items {
            group.enter()
            function(item) { channel, error in
                queue.sync { if let error = error { errors.append((channel: channel, error: error)) } }
                group.leave()
            }
        }
        
        group.notify(queue: queue) { completion?(errors) }
    }
    
    private func attemptReconnect(withIteration iteration: Int = -1) {
        guard shouldHandleRedirectsAutomatically else {
            reconnectIteration = nil
            channelsToRejoin = []
            return
        }
        
        reconnectIteration = iteration
        
        if iteration == -1 {
            channelsToRejoin = joinedChannels
            disconnect()
        }
        
        let delay = Double(max(Int(pow(2, Double(iteration - 1))), 0))
        print("Attempting reconnect after \(Int(delay)) seconds...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.connect()
        }
    }
    
    @ReaderWriterValue(wrappedValue: nil, Chatbot.self, propertyName: "reconnectIteration")
    private var reconnectIteration: Int?
    
    @ReaderWriterValue(Chatbot.self, propertyName: "channelsToRejoin")
    private var channelsToRejoin = [String]()
    
    @ReaderWriterValue(Chatbot.self, propertyName: "usersBeingAggregated")
    private var usersBeingAggregated = [String: Set<String>]()
    
    private var connection: NWConnection?
    private lazy var connectionQueue = DispatchQueue(for: Self.self, name: "connectionQueue")
}
