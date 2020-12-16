//
//  ChatMessageNotice.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

extension ChatMessage {
    
    /// General notices from the server.
    public struct Notice {
        
        /// The kind of notice.
        public enum Kind: String {
            
            /// // <user> is already banned in this channel.
            case alreadyBanned = "already_banned"
            
            /// This room is not in emote-only mode.
            case alreadyEmoteOnlyOff = "already_emote_only_off"
            
            /// This room is already in emote-only mode.
            case alreadyEmoteOnlyOn = "already_emote_only_on"
            
            /// This room is not in r9k mode.
            case alreadyR9kOff = "already_r9k_off"
            
            /// This room is already in r9k mode.
            case alreadyR9kOn = "already_r9k_on"
            
            /// This room is not in subscribers-only mode.
            case alreadySubsOff = "already_subs_off"
            
            /// This room is already in subscribers-only mode.
            case alreadySubsOn = "already_subs_on"
            
            /// You cannot ban admin <user>. Please email support@twitch.tv if an admin is being abusive.
            case badBanAdmin = "bad_ban_admin"
            
            /// You cannot ban anonymous users.
            case badBanAnon = "bad_ban_anon"
            
            /// You cannot ban the broadcaster.
            case badBanBroadcaster = "bad_ban_broadcaster"
            
            /// You cannot ban global moderator <user>. Please email support@twitch.tv if a global moderator is
            /// being abusive.
            case badBanGlobalMod = "bad_ban_global_mod"
            
            /// You cannot ban moderator <user> unless you are the owner of this channel.
            case badBanMod = "bad_ban_mod"
            
            /// You cannot ban yourself.
            case badBanSelf = "bad_ban_self"
            
            /// You cannot ban a staff <user>. Please email support@twitch.tv if a staff member is being abusive.
            case badBanStaff = "bad_ban_staff"
            
            /// Failed to start commercial.
            case badCommercialError = "bad_commercial_error"
            
            /// You cannot delete the broadcaster's messages.
            case badDeleteMessageBroadcaster = "bad_delete_message_broadcaster"
            
            /// You cannot delete messages from another moderator <user>.
            case badDeleteMessageMod = "bad_delete_message_mod"
            
            /// There was a problem hosting <channel>. Please try again in a minute.
            case badHostError = "bad_host_error"

            /// This channel is already hosting <channel>.
            case badHostHosting = "bad_host_hosting"

            /// Host target cannot be changed more than <number> times every half hour.
            case badHostRateExceeded = "bad_host_rate_exceeded"

            /// This channel is unable to be hosted.
            case badHostRejected = "bad_host_rejected"

            /// A channel cannot host itself.
            case badHostSelf = "bad_host_self"

            /// Sorry, /marker is not available through this client.
            case badMarkerClient = "bad_marker_client"

            /// <user> is banned in this channel. You must unban this user before granting mod status.
            case badModBanned = "bad_mod_banned"

            /// <user> is already a moderator of this channel.
            case badModMod = "bad_mod_mod"

            /// You cannot set slow delay to more than <number> seconds.
            case badSlowDuration = "bad_slow_duration"

            /// You cannot timeout admin <user>. Please email support@twitch.tv if an admin is being abusive.
            case badTimeoutAdmin = "bad_timeout_admin"

            /// You cannot timeout anonymous users.
            case badTimeoutAnon = "bad_timeout_anon"

            /// You cannot timeout the broadcaster.
            case badTimeoutBroadcaster = "bad_timeout_broadcaster"

            /// You cannot time a user out for more than <seconds>.
            case badTimeoutDuration = "bad_timeout_duration"

            /// You cannot timeout global moderator <user>. Please email support@twitch.tv if a global moderator
            /// is being abusive.
            case badTimeoutGlobalMod = "bad_timeout_global_mod"

            /// You cannot timeout moderator <user> unless you are the owner of this channel.
            case badTimeoutMod = "bad_timeout_mod"

            /// You cannot timeout yourself.
            case badTimeoutSelf = "bad_timeout_self"

            /// You cannot timeout staff <user>. Please email support@twitch.tv if a staff member is being abusive.
            case badTimeoutStaff = "bad_timeout_staff"

            /// <user> is not banned from this channel.
            case badUnbanNoBan = "bad_unban_no_ban"

            /// There was a problem exiting host mode. Please try again in a minute.
            case badUnhostError = "bad_unhost_error"

            /// <user> is not a moderator of this channel.
            case badUnmodMod = "bad_unmod_mod"

            /// <user> is now banned from this channel.
            case banSuccess = "ban_success"

            /// Commands available to you in this room (use /help <command> for details): <list of commands>
            case cmdsAvailable = "cmds_available"

            /// Your color has been changed.
            case colorChanged = "color_changed"

            /// Initiating <number> second commercial break. Keep in mind that your stream is still live and not
            /// everyone will get a commercial.
            case commercialSuccess = "commercial_success"

            /// The message from <user> is now deleted.
            case deleteMessageSuccess = "delete_message_success"

            /// This room is no longer in emote-only mode.
            case emoteOnlyOff = "emote_only_off"

            /// This room is now in emote-only mode.
            case emoteOnlyOn = "emote_only_on"

            /// This room is no longer in followers-only mode.
            ///
            /// Note: The followers tags are broadcast to a channel when a moderator makes changes.
            case followersOff = "followers_off"

            /// This room is now in <duration> followers-only mode.
            ///
            /// Examples: “This room is now in 2 week followers-only mode.” or “This room is now in 1 minute
            /// followers-only mode.”
            case followersOn = "followers_on"

            /// This room is now in followers-only mode.
            case followersOnzero = "followers_onzero"

            /// Exited host mode.
            case hostOff = "host_off"

            /// Now hosting <channel>.
            case hostOn = "host_on"

            /// <user> is now hosting you.
            case hostSuccess = "host_success"

            /// <user> is now hosting you for up to <number> viewers.
            case hostSuccessViewers = "host_success_viewers"

            /// <channel> has gone offline. Exiting host mode.
            case hostTargetWentOffline = "host_target_went_offline"

            /// <number> host commands remaining this half hour.
            case hostsRemaining = "hosts_remaining"

            /// Invalid username: <user>
            case invalidUser = "invalid_user"

            /// You have added <user> as a moderator of this channel.
            case modSuccess = "mod_success"

            /// You are permanently banned from talking in <channel>.
            case msgBanned = "msg_banned"

            /// Your message was not sent because it contained too many characters that could not be processed.
            /// If you believe this is an error, rephrase and try again.
            case msgBadCharacters = "msg_bad_characters"

            /// Your message was not sent because your account is not in good standing in this channel.
            case msgChannelBlocked = "msg_channel_blocked"

            /// This channel has been suspended.
            case msgChannelSuspended = "msg_channel_suspended"

            /// Your message was not sent because it is identical to the previous one you sent, less than 30
            /// seconds ago.
            case msgDuplicate = "msg_duplicate"

            /// This room is in emote only mode. You can find your currently available emoticons using the smiley
            /// in the chat text area.
            case msgEmoteonly = "msg_emoteonly"

            /// You must use Facebook Connect to send messages to this channel. You can see Facebook Connect in
            /// your Twitch settings under the connections tab.
            case msgFacebook = "msg_facebook"

            /// This room is in <duration> followers-only mode. Follow <channel> to join the community!
            ///
            /// Note: These msg_followers tags are kickbacks to a user who does not meet the criteria; that is,
            /// does not follow or has not followed long enough.
            case msgFollowersonly = "msg_followersonly"

            /// This room is in <duration1> followers-only mode. You have been following for <duration2>. Continue
            /// following to chat!
            case msgFollowersonlyFollowed = "msg_followersonly_followed"

            /// This room is in followers-only mode. Follow <channel> to join the community!
            case msgFollowersonlyZero = "msg_followersonly_zero"

            /// This room is in r9k mode and the message you attempted to send is not unique.
            case msgR9k = "msg_r9k"

            /// Your message was not sent because you are sending messages too quickly.
            case msgRatelimit = "msg_ratelimit"

            /// Hey! Your message is being checked by mods and has not been sent.
            case msgRejected = "msg_rejected"

            /// Your message wasn't posted due to conflicts with the channel's moderation settings.
            case msgRejectedMandatory = "msg_rejected_mandatory"

            /// The room was not found.
            case msgRoomNotFound = "msg_room_not_found"

            /// This room is in slow mode and you are sending messages too quickly. You will be able to talk again
            /// in <number> seconds.
            case msgSlowmode = "msg_slowmode"

            /// This room is in subscribers only mode. To talk, purchase a channel subscription at
            /// https://www.twitch.tv/products/<broadcaster login name>/ticket?ref=subscriber_only_mode_chat.
            case msgSubsonly = "msg_subsonly"

            /// Your account has been suspended.
            case msgSuspended = "msg_suspended"

            /// You are banned from talking in <channel> for <number> more seconds.
            case msgTimedout = "msg_timedout"

            /// This room requires a verified email address to chat. Please verify your email at
            /// https://www.twitch.tv/settings/profile.
            case msgVerifiedEmail = "msg_verified_email"

            /// No help available.
            case noHelp = "no_help"

            /// There are no moderators of this channel.
            case noMods = "no_mods"

            /// No channel is currently being hosted.
            case notHosting = "not_hosting"

            /// You don’t have permission to perform that action.
            case noPermission = "no_permission"

            /// This room is no longer in r9k mode.
            case r9kOff = "r9k_off"

            /// This room is now in r9k mode.
            case r9kOn = "r9k_on"

            /// You already have a raid in progress.
            case raidErrorAlreadyRaiding = "raid_error_already_raiding"

            /// You cannot raid this channel.
            case raidErrorForbidden = "raid_error_forbidden"

            /// A channel cannot raid itself.
            case raidErrorSelf = "raid_error_self"

            /// Sorry, you have more viewers than the maximum currently supported by raids right now.
            case raidErrorTooManyViewers = "raid_error_too_many_viewers"

            /// There was a problem raiding <channel>. Please try again in a minute.
            case raidErrorUnexpected = "raid_error_unexpected"

            /// This channel is intended for mature audiences.
            case raidNoticeMature = "raid_notice_mature"

            /// This channel has follower or subscriber only chat.
            case raidNoticeRestrictedChat = "raid_notice_restricted_chat"

            /// The moderators of this channel are: <list of users>
            case roomMods = "room_mods"

            /// This room is no longer in slow mode.
            case slowOff = "slow_off"

            /// This room is now in slow mode. You may send messages every <number> seconds.
            case slowOn = "slow_on"

            /// This room is no longer in subscribers-only mode.
            case subsOff = "subs_off"

            /// This room is now in subscribers-only mode.
            case subsOn = "subs_on"

            /// <user> is not timed out from this channel.
            case timeoutNoTimeout = "timeout_no_timeout"

            /// <user> has been timed out for <duration> seconds.
            case timeoutSuccess = "timeout_success"

            /// The community has closed channel <channel> due to Terms of Service violations.
            case tosBan = "tos_ban"

            /// Only turbo users can specify an arbitrary hex color. Use one of the following instead:
            /// <list of colors>.
            case turboOnlyColor = "turbo_only_color"
            
            /// Sorry, "<command>" is not available through this client.
            case unavailableCommand = "unavailable_command"

            /// <user> is no longer banned from this channel.
            case unbanSuccess = "unban_success"

            /// You have removed <user> as a moderator of this channel.
            case unmodSuccess = "unmod_success"

            /// You do not have an active raid.
            case unraidErrorNoActiveRaid = "unraid_error_no_active_raid"

            /// There was a problem stopping the raid. Please try again in a minute.
            case unraidErrorUnexpected = "unraid_error_unexpected"

            /// The raid has been cancelled.
            case unraidSuccess = "unraid_success"

            /// Unrecognized command: <command>
            case unrecognizedCmd = "unrecognized_cmd"

            /// The command <command> cannot be used in a chatroom.
            case unsupportedChatroomsCmd = "unsupported_chatrooms_cmd"

            /// <user> is permanently banned. Use "/unban" to remove a ban.
            case untimeoutBanned = "untimeout_banned"

            /// <user> is no longer timed out in this channel.
            case untimeoutSuccess = "untimeout_success"

            /// Usage: “/ban <username> [reason]” Permanently prevent a user from chatting. Reason is optional and
            /// will be shown to the target and other moderators. Use “/unban” to remove a ban.
            case usageBan = "usage_ban"

            /// Usage: “/clear” Clear chat history for all users in this room.
            case usageClear = "usage_clear"

            /// Usage: “/color” <color> Change your username color. Color must be in hex (#000000) or one of the
            /// following: Blue, BlueViolet, CadetBlue, Chocolate, Coral, DodgerBlue, Firebrick, GoldenRod, Green,
            /// HotPink, OrangeRed, Red, SeaGreen, SpringGreen, YellowGreen.
            case usageColor = "usage_color"

            /// Usage: “/commercial [length]” Triggers a commercial. Length (optional) must be a positive number
            /// of seconds.
            case usageCommercial = "usage_commercial"

            /// Usage: “/disconnect” Reconnects to chat.
            case usageDisconnect = "usage_disconnect"

            /// Usage: /emoteonlyoff” Disables emote-only mode.
            case usageEmoteOnlyOff = "usage_emote_only_off"

            /// Usage: “/emoteonly” Enables emote-only mode (only emoticons may be used in chat). Use
            /// /emoteonlyoff to disable.
            case usageEmoteOnlyOn = "usage_emote_only_on"

            /// Usage: /followersoff” Disables followers-only mode.
            case usageFollowersOff = "usage_followers_off"

            /// Usage: “/followers Enables followers-only mode (only users who have followed for “duration” may
            /// chat). Examples: “30m”, “1 week”, “5 days 12 hours”. Must be less than 3 months.
            case usageFollowersOn = "usage_followers_on"

            /// Usage: “/help” Lists the commands available to you in this room.
            case usageHelp = "usage_help"

            /// Usage: “/host <channel>” Host another channel. Use “/unhost” to unset host mode.
            case usageHost = "usage_host"

            /// Usage: “/marker <optional comment>” Adds a stream marker (with an optional comment, max 140
            /// characters) at the current timestamp. You can use markers in the Highlighter for easier editing.
            case usageMarker = "usage_marker"

            /// Usage: “/me <message>” Send an “emote” message in the third person.
            case usageMe = "usage_me"

            /// Usage: “/mod <username>” Grant mod status to a user. Use “/mods” to list the moderators of this
            /// channel.
            case usageMod = "usage_mod"

            /// Usage: “/mods” Lists the moderators of this channel.
            case usageMods = "usage_mods"

            /// Usage: “/r9kbetaoff” Disables r9k mode.
            case usageR9kOff = "usage_r9k_off"

            /// Usage: “/r9kbeta” Enables r9k mode. Use “/r9kbetaoff“ to disable.
            case usageR9kOn = "usage_r9k_on"

            /// Usage: “/raid <channel>” Raid another channel. Use “/unraid” to cancel the Raid.
            case usageRaid = "usage_raid"

            /// Usage: “/slowoff” Disables slow mode.
            case usageSlowOff = "usage_slow_off"

            /// Usage: “/slow” [duration] Enables slow mode (limit how often users may send messages). Duration
            /// (optional, default=<number>) must be a positive integer number of seconds. Use “/slowoff” to
            /// disable.
            case usageSlowOn = "usage_slow_on"

            /// Usage: “/subscribersoff” Disables subscribers-only mode.
            case usageSubsOff = "usage_subs_off"

            /// Usage: “/subscribers” Enables subscribers-only mode (only subscribers may chat in this channel).
            /// Use “/subscribersoff” to disable.
            case usageSubsOn = "usage_subs_on"

            /// Usage: “/timeout <username> [duration][time unit] [reason]" Temporarily prevent a user from
            /// chatting. Duration (optional, default=10 minutes) must be a positive integer; time unit (optional,
            /// default=s) must be one of s, m, h, d, w; maximum duration is 2 weeks. Combinations like 1d2h are
            /// also allowed. Reason is optional and will be shown to case the target user and other moderators.
            /// Use “untimeout” to remove a timeout.
            case usageTimeout = "usage_timeout"

            /// Usage: “/unban <username>” Removes a ban on a user.
            case usageUnban = "usage_unban"

            /// Usage: “/unhost” Stop hosting another channel.
            case usageUnhost = "usage_unhost"

            /// Usage: “/unmod <username>” Revoke mod status from a user. Use “/mods” to list the moderators of
            /// this channel.
            case usageUnmod = "usage_unmod"

            /// Usage: “/unraid” Cancel the Raid.
            case usageUnraid = "usage_unraid"

            /// Usage: “/raid <username>” Removes a timeout on a user.
            case usageUntimeout = "usage_untimeout"

            /// You have been banned from sending whispers.
            case whisperBanned = "whisper_banned"

            /// That user has been banned from receiving whispers.
            case whisperBannedRecipient = "whisper_banned_recipient"

            /// Usage: <login> <message>
            case whisperInvalidArgs = "whisper_invalid_args"

            /// No user matching that login.
            case whisperInvalidLogin = "whisper_invalid_login"

            /// You cannot whisper to yourself.
            case whisperInvalidSelf = "whisper_invalid_self"

            /// You are sending whispers too fast. Try again in a minute.
            case whisperLimitPerMin = "whisper_limit_per_min"

            /// You are sending whispers too fast. Try again in a second.
            case whisperLimitPerSec = "whisper_limit_per_sec"

            /// Your settings prevent you from sending this whisper.
            case whisperRestricted = "whisper_restricted"

            /// That user's settings prevent them from receiving this whisper.
            case whisperRestrictedRecipient = "whisper_restricted_recipient"
        }
        
        /// The notice message.
        public let message: String
        
        /// The name of the channel the notice was sent to.
        public let channel: String
        
        /// The kind of notice.
        public let kind: Kind
        
        internal init(dictionary: [String: String]) throws {
            guard let message = dictionary["message"],
                  let channel = dictionary["channel"],
                  let messageId = dictionary["msg-id"],
                  let kind = Kind(rawValue: messageId) else {
                throw ChatMessageError.unhandledMessage
            }
            
            self.message = message
            self.channel = channel
            self.kind = kind
        }
    }
}
