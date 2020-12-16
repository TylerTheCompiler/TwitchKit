//
//  PubSubMessage.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/22/20.
//

extension PubSub {
    
    /// Describes a message received via PubSub.
    public enum Message: Decodable {
        
        /// An error relating to PubSub messages.
        public enum Error: Swift.Error {
            
            /// The PubSub message could not be created due to a missing topic `userInfo` value.
            case missingTopicUserInfoValue
        }
        
        /// Describes the type of a whisper event, whether it was sent, received, or a thread event.
        public enum WhisperEventType: String, Decodable {
            
            /// The whisper was sent.
            case sent = "whisper_sent"
            
            /// A whisper was received.
            case received = "whisper_received"
            
            /// A whisper thread event occurred.
            case thread
        }
        
        /// A message that is received when anyone cheers in a specified channel. (Version 1)
        case bitsV1(BitsEvent)
        
        /// A message that is received when anyone cheers in a specified channel. (Version 2)
        case bitsV2(BitsEvent)
        
        /// A message that is received when a user earns a new Bits badge in a particular channel, and chooses to
        /// share the notification with chat.
        case bitsBadgeUnlock(BitsBadgeEvent)
        
        /// A message that is received when a custom reward is redeemed in a channel.
        case channelPoints(ChannelPointsEvent)
        
        /// A message that is received when anyone subscribes (first month), resubscribes (subsequent months), or
        /// gifts a subscription to a channel. Subgift subscription messages contain recipient information.
        case channelSubscription(SubscriptionEvent)
        
        /// Supports moderators listening to the topic, as well as users listening to the topic to receive their own
        /// events.
        ///
        /// Examples of moderator actions are bans, unbans, timeouts, deleting messages, changing chat mode
        /// (followers-only, subs-only), changing AutoMod levels, and adding a mod.
        case moderatorAction(ModerationEvent)
        
        /// A message that is received when anyone whispers the specified user.
        case whisperReceived(WhisperEvent)
        
        /// A message that is received when the user whispers another user.
        case whisperSent(WhisperEvent)
        
        /// A message that is received when the user receives a whisper thread event.
        case whisperThread(WhisperThreadEvent)
        
        /// A message that is received when the server is about to restart (typically for maintenance) and will
        /// disconnect the client within 30 seconds. During this time, Twitch recommends that clients reconnect to
        /// the server; otherwise, the client will be forcibly disconnected.
        case reconnect
        
        public init(from decoder: Decoder) throws {
            let optionalTopic = decoder.userInfo[.init("topic")] as? Topic
            
            guard let topic = optionalTopic else { throw Error.missingTopicUserInfoValue }
            
            let container = try decoder.singleValueContainer()
            
            switch topic {
            case .bitsV1:
                self = try .bitsV1(container.decode(BitsEvent.self))
                
            case .bitsV2:
                self = try .bitsV2(container.decode(BitsEvent.self))
                
            case .bitsBadgeUnlocks:
                self = try .bitsBadgeUnlock(container.decode(BitsBadgeEvent.self))
                
            case .channelPoints:
                self = try .channelPoints(container.decode(ChannelPointsEvent.self))
                
            case .channelSubscriptions:
                self = try .channelSubscription(container.decode(SubscriptionEvent.self))
                
            case .moderatorActions:
                self = try .moderatorAction(container.decode(ModerationEvent.self))
                
            case .whispers:
                let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
                let whisperType = try keyedContainer.decode(WhisperEventType.self, forKey: .type)
                switch whisperType {
                case .sent:
                    self = try .whisperSent(container.decode(WhisperEvent.self))
                    
                case .received:
                    self = try .whisperReceived(container.decode(WhisperEvent.self))
                    
                case .thread:
                    self = try .whisperThread(container.decode(WhisperThreadEvent.self))
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case type
        }
    }
}
